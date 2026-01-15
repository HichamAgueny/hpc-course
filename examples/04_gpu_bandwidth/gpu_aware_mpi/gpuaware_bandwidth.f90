program gpuaware_mpiacc

  use mpi
  use openacc

  implicit none

  integer, parameter :: dp = selected_real_kind(15, 307)  ! double precision
  integer, parameter :: n_warmup = 5
  integer, parameter :: n_iter = 50
  integer, parameter :: float_size_bytes = 8  ! double precision

  integer :: myid, nproc, ierr
  integer :: host_rank, host_comm
  integer :: myDevice, numDevice
  integer :: result_len
  integer(kind=8) :: nx, nx_max_bytes, message_bytes
  integer :: i, tag0, tag1
  integer :: status(MPI_STATUS_SIZE)

  double precision :: start_time, end_time, elapsed_time
  double precision :: avg_time_per_transfer, bandwidth_GBps
  double precision, allocatable :: f(:)

  character(len=MPI_MAX_PROCESSOR_NAME) :: proc_name

  ! ----------------------------------------------------------------------
  ! MPI Initialization
  ! ----------------------------------------------------------------------
  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, myid, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nproc, ierr)

  ! Require exactly 2 ranks 
  if (nproc /= 2) then
     if (myid == 0) then
        write(*,'(A,I0,A)') "Error: This program is designed for 2 MPI ranks. You provided: ", nproc
     endif
     call MPI_Finalize(ierr)
     stop
  endif

  ! Split communicator for shared memory (to map GPUs)
  ! Split the world communicator into subgroups of commu, each of which
! contains processes that run on the same node, and which can create a
! shared memory region (via the type MPI_COMM_TYPE_SHARED).
! The call returns a new communicator "host_comm", which is created by
! each subgroup.
  call MPI_Comm_split_type(MPI_COMM_WORLD, MPI_COMM_TYPE_SHARED, 0, &
                           MPI_INFO_NULL, host_comm, ierr)
  call MPI_Comm_rank(host_comm, host_rank, ierr)

  ! Get processor name (optional)
  call MPI_Get_processor_name(proc_name, result_len, ierr)

  ! Set OpenACC device
  myDevice = host_rank
  numDevice = acc_get_num_devices(acc_get_device_type())
  call acc_set_device_num(myDevice, acc_get_device_type())

  if (myid == 0) then
     print *, ""
     print *, "-- Measuring Bandwidth (GB/s) - MPI + OpenACC Ping-Pong --"
     print *, "-- Nbr of GPUs per node: ", numDevice
     print *, ""
  endif

  ! Max transfer size: 1 GB (in bytes)
  nx_max_bytes = 1_8 * 1024_8**3  ! 1 GiB ~ 1.07e9 bytes, but we use 2^i scaling

  ! Loop over message sizes: from 8 bytes (1 double) to ~1 GB
  nx = 1_8
  tag0 = 1
  tag1 = 2

  do while (nx * float_size_bytes <= nx_max_bytes)

     ! Allocate GPU-resident array
     allocate(f(nx))

     ! Initialize on host (only rank 0 needs real data; others can use zeros)
     if (myid == 0) then
        call random_number(f)
     else
        f = 0.0_dp
     endif

     ! Copy to GPU
     !$acc enter data copyin(f)

     ! --------------------------
     ! Warm-up
     ! --------------------------
     do i = 1, n_warmup
        !$acc host_data use_device(f)
        if (myid == 0) then
           call MPI_Send(f, nx, MPI_DOUBLE_PRECISION, 1, tag0, MPI_COMM_WORLD, ierr)
           call MPI_Recv(f, nx, MPI_DOUBLE_PRECISION, 1, tag1, MPI_COMM_WORLD, status, ierr)
        else if (myid == 1) then
           call MPI_Recv(f, nx, MPI_DOUBLE_PRECISION, 0, tag0, MPI_COMM_WORLD, status, ierr)
           call MPI_Send(f, nx, MPI_DOUBLE_PRECISION, 0, tag1, MPI_COMM_WORLD, ierr)
        endif
        !$acc end host_data
     enddo

     ! --------------------------
     ! Timed iterations
     ! --------------------------
     call MPI_Barrier(MPI_COMM_WORLD, ierr)
     start_time = MPI_Wtime()

     do i = 1, n_iter
        !$acc host_data use_device(f)
        if (myid == 0) then
           call MPI_Send(f, nx, MPI_DOUBLE_PRECISION, 1, tag0, MPI_COMM_WORLD, ierr)
           call MPI_Recv(f, nx, MPI_DOUBLE_PRECISION, 1, tag1, MPI_COMM_WORLD, status, ierr)
        else if (myid == 1) then
           call MPI_Recv(f, nx, MPI_DOUBLE_PRECISION, 0, tag0, MPI_COMM_WORLD, status, ierr)
           call MPI_Send(f, nx, MPI_DOUBLE_PRECISION, 0, tag1, MPI_COMM_WORLD, ierr)
        endif
        !$acc end host_data
     enddo

     end_time = MPI_Wtime()
     elapsed_time = end_time - start_time

     ! --------------------------
     ! Compute bandwidth
     ! --------------------------
     if (myid == 0) then
        ! Size of ONE message in bytes
        message_bytes = nx * float_size_bytes

        ! Each iteration has 2 transfers (send + recv), so:
        ! Total transfers = 2 * n_iter
        ! Average time per ONE-WAY transfer:
        avg_time_per_transfer = elapsed_time / (2.0_dp * real(n_iter, dp))

        ! Bandwidth in GB/s (1 GB = 1e9 bytes standard in HPC)
        bandwidth_GBps = (real(message_bytes, dp) / avg_time_per_transfer) * 1.0e-9_dp

        ! Output (skip tiny sizes)
        if (message_bytes >= 64) then
           write(*,'(A,I12,A,F12.6,A,F12.3,A)') &
                " Size (B): ", message_bytes, &
                " | Time/transfer (s): ", avg_time_per_transfer, &
                " | Bandwidth (GB/s): ", bandwidth_GBps
        endif
     endif

     !$acc exit data delete(f)
     deallocate(f)

     ! Next size: double the number of doubles
     nx = nx * 2
  enddo

  call MPI_Finalize(ierr)

end program gpuaware_mpiacc
