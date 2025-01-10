      subroutine optindval(veg,numplt,numspc,clusid,numcls,  &
                        relfrq,relabu,indval,indcls,clstab,  &
                        maxcls,sumind,maxitr,minsiz,sums,    &
                        numitr,tmpclu)
 
!* passed in/out
 
      integer numplt
      integer numspc
      integer clusid(numplt)
      integer numcls
      integer maxitr
      integer minsiz
      integer numitr
      double precision veg(numplt,numspc)
      double precision sums(0:maxitr)
 
!* passed through to clcdul
 
      double precision relfrq(numspc,numcls)
      double precision relabu(numspc,numcls)
      double precision indval(numspc,numcls)
      double precision indcls(numspc)
      double precision sumind
      integer clstab(numcls)
      integer maxcls(numspc)
 
!* scratch arrays
 
      integer tmpclu(numplt)

!* local
 
      double precision base
      integer moveto
      integer mvefrm
      integer plttrn
      integer flag
 
!********************* one ******************************
 
      call clcdul(veg,numplt,numspc,clusid,numcls,relfrq,relabu,   &
                  indval,indcls,clstab,maxcls,sumind)

      base = sumind
      numitr = maxitr
      sums(0) = sumind

      do i=1,numcls
        clstab(i) = 0
      end do    

      do i=1,numplt
        clstab(clusid(i)) = clstab(clusid(i)) + 1
      end do   
 
      mvefrm = 0
      moveto = 0
      plttrn = 0

      do k=1,maxitr
        flag = 0
        do i=1,numplt
          mvefrm = 0
          moveto = 0
          plttrn = 0
          do j=1,numplt
            tmpclu(j) = clusid(j)
          end do  
 
          do j=1,numcls
            if (j .eq. clusid(i)) cycle
            if (clstab(clusid(i)) .le. minsiz) cycle
            tmpclu(i) = j
            call clcdul(veg,numplt,numspc,tmpclu,numcls,relfrq,     &
                        relabu,indval,indcls,clstab,maxcls,sumind)
            if (sumind .gt. base) then
              base = sumind
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
          sumind = base
        else
          numitr = k 
          return
        endif
      end do   
 
      return
 
      end
