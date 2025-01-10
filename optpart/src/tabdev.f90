      subroutine tabdev(tab,nrow,ncol,mu,ntypes,devian,    &
                        totdev,pval,nitr,relsum,colsum,    &
                        spcsum,pclass,tclass)
 
!* passed
 
      integer nrow
      integer ncol
      integer ntypes
      double precision tab(nrow,ncol)
      integer mu(nrow)
      double precision devian(ncol)
      double precision totdev
      double precision pval(ncol)
      integer nitr
      double precision relsum(ntypes)
      double precision colsum(ntypes)
      double precision spcsum(ncol)
      integer pclass(nrow)
      integer tclass(nrow)
 
!* local
 
      double precision tmpdev
 
!* tabdev ******************** one ****************************
 
      do i=1,ncol
        do j=1,nrow
          colsum(mu(j)) = colsum(mu(j)) + tab(j,i)
          spcsum(i) = spcsum(i) + tab(j,i)
        end do  
 
        do j=1,ntypes
          relsum(j) = colsum(j)/spcsum(i)
          if (relsum(j) .gt. 0) then
            totdev = totdev - 2 * log(relsum(j)) * colsum(j)
            devian(i) = devian(i) - 2 * log(relsum(j)) * colsum(j)
          endif
          colsum(j) = 0.0
        end do  
      end do  
 
!* tabdev ***************** two ********************************
 
      do i=1,ncol
        pval(i) = 0.0
        do j=1,nitr
          tmpdev = 0.0
          call permute(mu,pclass,nrow,tclass)
          do k=1,ntypes
            colsum(k) = 0.0
          end do   
 
          do k=1,nrow
            colsum(pclass(k)) = colsum(pclass(k)) + tab(k,i)
          end do    
 
          do k=1,ntypes
            relsum(k) = colsum(k)/spcsum(i)
            if (relsum(k) .gt. 0) then
              tmpdev = tmpdev - 2 * log(relsum(k)) * colsum(k)
            endif
          end do    
          if (tmpdev .le. devian(i)) then
            pval(i) = pval(i) + 1
          endif
        end do    
        pval(i) = (pval(i)+1) / (nitr+1) 
      end do   
 
      return
 
      end
