      subroutine clcdev(tab,nrow,ncol,mu,ntypes,totdev,     &
                 relsum,colsum,spcsum)
!
!* passed in
!
      integer nrow
      integer ncol
      integer ntypes
      double precision tab(nrow,ncol)
      integer mu(nrow)
      double precision relsum(ntypes)
      double precision colsum(ntypes)
      double precision spcsum(ncol)
!
!* passed back
!
      double precision totdev
!
!* tabdev ******************** one ****************************
!
      totdev = 0.0
!
      do i=1,ncol
        spcsum(i) = 0.0
        colsum = (/ (0,i=1,ntypes) /)
!
        do j=1,nrow
          colsum(mu(j)) = colsum(mu(j)) + tab(j,i)
          spcsum(i) = spcsum(i) + tab(j,i)
        end do   
!
        do j=1,ntypes
          relsum(j) = colsum(j)/spcsum(i)
          if (relsum(j) .gt. 0) then
            totdev = totdev - 2 * log(relsum(j)) * colsum(j)
          endif
        end do    
      end do  
!
      return
!
      end
