!======================================================================!
SUBROUTINE WRITE_NET_CDF_2DI (data_out)
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Write a 2D integer netCDF file.
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
USE MPI    ! Enable access to the Message Passing Interface library of
           ! parallel routines.
USE NETCDF ! Enable access to the library of netCDF routines.
USE SHARED ! Shared variables.
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
IMPLICIT NONE
!----------------------------------------------------------------------!

INTEGER, INTENT (IN) :: data_out (lon_c,lat_c)

!----------------------------------------------------------------------!
INTEGER :: ncid             ! netCDF ID.
INTEGER :: x_dimid,y_dimid  ! Dimension IDs.
INTEGER :: dimids_two (2)   ! Array of dimids.
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Create a netCDF file "chunk.nc". The 'CHECK' wrapping checks the
! return code to make sure any return not equal to nf90noerr (0) will
! print a netCDF error message and exit.
! nf90_create creates a new netCDF dataset, returing a netCDF ID.
! The new dataset is opened for write access and placed in define mode.
! The NF90_NETCDF4 flag causes a HDF5/netCDF-4 file to be created.
! The NF90_MPIIO flag selects MPI/IO (rather than MPI/POSIX).
! The comm and info parameters cause parallel I/O to be enabled.
!----------------------------------------------------------------------!
CALL CHECK (nf90_create(TRIM(file_name),IOR(NF90_NETCDF4, NF90_MPIIO), &
  ncid, comm = MPI_COMM_WORLD, info = MPI_INFO_NULL))
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Define the dimensions. netCDF hands back an ID for each.
! Metadata operations must take place on all processors.
!----------------------------------------------------------------------!
CALL CHECK (nf90_def_dim(ncid, "x", NX, x_dimid))
CALL CHECK (nf90_def_dim(ncid, "y", NY, y_dimid))
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! The dimids array is used to pass the IDs of the dimensions of the
! variables. Note that in Fortran arrays are stored in column-major
! format (i.e. leftmost indices vary fastest).
!----------------------------------------------------------------------!
dimids_two = (/x_dimid,y_dimid/)
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Define the variable.
!----------------------------------------------------------------------!
CALL CHECK (nf90_def_var(ncid, TRIM(var_name), NF90_int, dimids_two, &
  varid))
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! End define mode. This tells netCDF we are done defining metadata.
! This operation is collective and all processors will write their
! metadata to disk.
!----------------------------------------------------------------------!
CALL CHECK (nf90_enddef(ncid))
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Set up the position and dimensions of the chunk to write.
!----------------------------------------------------------------------!
start_two = (/lon_s,lat_s/)
count_two = (/lon_c,lat_c/)
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Write the data to the netCDF file. Each processor writes one chunk.
!----------------------------------------------------------------------!
CALL CHECK(nf90_put_var(ncid, varid, data_out, start = start_two, &
  count = count_two))
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
! Close the netCDF file.
!----------------------------------------------------------------------!
CALL CHECK (nf90_close(ncid))
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
CONTAINS
  SUBROUTINE CHECK (status)
    INTEGER, INTENT (IN) :: status

    IF (status /= nf90_noerr) THEN
      PRINT *, TRIM (nf90_strerror(status))
      STOP "Stopped"
    END IF
  END SUBROUTINE CHECK
!----------------------------------------------------------------------!

!----------------------------------------------------------------------!
END SUBROUTINE WRITE_NET_CDF_2D
!======================================================================!

