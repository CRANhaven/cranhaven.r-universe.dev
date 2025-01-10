      subroutine opttdev(veg,numplt,numspc,clusid,numcls,     &
                        maxitr,minsiz,sums,numitr,            &
                        relsum,colsum,spcsum,tmpclu)
 
!* passed in/out
 
      integer numplt
      integer numspc
      integer maxitr
      integer numcls
      integer minsiz
      integer numitr
      integer clusid(numplt)
      double precision veg(numplt,numspc)
      double precision sums(0:maxitr)
      double precision relsum(numcls)
      double precision colsum(numcls)
      double precision spcsum(numspc)
      integer tmpclu(numplt)
 
!* local
 
      double precision base
      double precision totdev
      integer clstab(numcls)
      integer moveto
      integer mvefrm
      integer plttrn
      integer flag
 
!********************* one ******************************
 
      call clcdev(veg,numplt,numspc,clusid,numcls,totdev,      &
                    relsum,colsum,spcsum)
      base = totdev
      numitr = maxitr
      sums(0) = totdev

      clstab = (/ (0,i=1,numcls) /)

      do i=1,numplt
        clstab(clusid(i)) = clstab(clusid(i)) + 1
      end do  
 
      do k=1,maxitr
        flag = 0
        mvefrm = 0
        moveto = 0
        do i=1,numplt
          tmpclu = (/ (clusid(i), i=1,numplt) /)
          do j=1,numcls
            if (j .eq. clusid(i)) cycle
            if (clstab(clusid(i)) .le. minsiz) cycle
            tmpclu(i) = j
            call clcdev(veg,numplt,numspc,tmpclu,numcls,totdev,      &
                       relsum,colsum,spcsum) 
            if (totdev .lt. base) then
              base = totdev
              moveto = tmpclu(i)
              mvefrm = clusid(i)
              plttrn = i
              flag = 1
            endif
          end do    
        end do   
        if (flag .eq. 1) then
          clusid(plttrn) = moveto
          clstab(moveto) = clstab(moveto) + 1
          clstab(mvefrm) = clstab(mvefrm) - 1
          sums(k) = base
        else
          numitr = k 
          return
        endif
      end do    
!
      return
!
      end
