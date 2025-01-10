      subroutine clcdul(veg,numplt,numspc,clusid,numcls,   &
                 relfrq,relabu,indval,indcls,              &
                 clstab,maxcls,sumind)
!
! passed in
!
      integer numplt
      integer numspc
      integer numcls
      integer clusid(numplt)
      double precision veg(numplt,numspc)
      double precision relfrq(numspc,numcls)
      double precision relabu(numspc,numcls)
      double precision indval(numspc,numcls)
      double precision indcls(numspc)
      integer clstab(numcls)
      integer maxcls(numspc)
!
! passed back
!
      double precision sumind
!
! local 
! 
      double precision maxval
      double precision totveg
      double precision sumrab
!
!*********************************** one *********************************
!
      do i=1,numcls
        clstab(i) = 0
      end do  
!
      do i=1,numspc
        do j=1,numcls 
          relabu(i,j) = 0.0
          relfrq(i,j) = 0.0  
          indval(i,j) = 0.0
        end do   
      end do   
!
      do i=1,numplt
        clstab(clusid(i)) = clstab(clusid(i)) + 1
      end do   
!
      sumind = 0.0
!
!****************************** two **********************************
!
      do i=1,numspc
        totveg = 0
        do j=1,numplt
          if (veg(j,i) .gt. 0) then
            totveg = totveg + veg(j,i)
            relabu(i,clusid(j)) = relabu(i,clusid(j)) + veg(j,i)
            relfrq(i,clusid(j)) = relfrq(i,clusid(j)) + 1
          endif
        end do   
!
        sumrab = 0.0
        do j=1,numcls
          relabu(i,j) = relabu(i,j) / clstab(j)
          sumrab = sumrab + relabu(i,j)
          relfrq(i,j) = relfrq(i,j) / clstab(j)
        end do   
!
        maxval = 0
        do j=1,numcls
          relabu(i,j) = relabu(i,j) / sumrab
          indval(i,j) = relabu(i,j) * relfrq(i,j)
          if (indval(i,j) .gt. maxval) then
            maxval = indval(i,j)
            maxcls(i) = j
          endif
        end do   
        indcls(i) = maxval
      end do    
!
      do i=1,numspc
!       sumind = sumind + indcls(i) * clstab(maxcls(i))
        sumind = sumind + indcls(i)
      end do     
!
      return
!
      end
