      subroutine archi(dis,thresh,clusid,numplt)
!
!* passed
!
      integer numplt
      double precision dis(numplt,numplt)
      double precision thresh
      integer clusid(numplt)
!
!* local
!
      integer numclt
!

      numclt = 0
      clusid = (/ (0,i=1,numplt) /)
!
      do i=1,numplt
        if (clusid(i) .eq. 0) then
          numclt = numclt + 1
          clusid(i) = numclt                   ! set the seed
   10       do j=1,numplt
            if (clusid(j) .eq. 0) then
              do k=1,numplt
              if (clusid(k) .ne. numclt) cycle
              if (dis(j,k) .le. thresh) then
                  clusid(j) = numclt
                  goto 10
              endif
              end do  
            endif
          end do  
        endif
      end do  
!
      end
