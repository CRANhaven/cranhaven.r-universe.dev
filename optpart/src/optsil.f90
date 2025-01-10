      subroutine optsil(simptp,clusid,numplt,numclu,maxitr,sils,    &
                 numitr,simptc,pltsil,tmpclu,nabor,sumnum,sumden)
 
! passed in/out
 
      integer numplt
      integer numclu
      integer maxitr
      integer numitr
      integer clusid(numplt)
      double precision simptp(numplt,numplt)
      double precision sils(maxitr)
      double precision sumnum(numclu)
      integer sumden(numclu)
      double precision simptc(numplt,numclu)
      double precision pltsil(numplt)
      integer nabor(numplt)
      integer tmpclu(numplt)
 
! local
 
      double precision base
      double precision maxdel
      double precision newbas
      double precision totsil
      integer moveto
      integer plttrn
      integer flag
 
      call ptc(simptp,numplt,numclu,clusid,simptc,sumnum,sumden)
      call silho(simptc,clusid,numplt,numclu,pltsil,totsil,nabor)
      base = totsil
 
      do k=1,maxitr
        maxdel = 0.0
        flag = 0
        do i=1,numplt
          do j=1,numplt
            tmpclu(j) = clusid(j)
          end do   
 
          do j=1,numclu
            if (j .eq. clusid(i)) cycle
            tmpclu(i) = j
            call ptc(simptp,numplt,numclu,tmpclu,simptc,sumnum,sumden)
            call silho(simptc,tmpclu,numplt,numclu,pltsil,totsil,nabor)
            if ((totsil - base) .gt. maxdel) then
              maxdel = totsil - base
              newbas = totsil
              from = clusid(i)
              moveto = tmpclu(i)
              plttrn = i
              flag = 1
            endif
          end do   
        end do   
        if (flag .eq. 1) then
          clusid(plttrn) = moveto
          base = newbas
          sils(k) = base
        else
          numitr = k - 1
          return
        endif
      end do   
 
      numitr = maxitr
 
      return
 
      end


      subroutine silho(simptc,clusid,numplt,numclu,pltsil,totsil,nabor)
 
! passed in
 
      integer numplt
      integer numclu
      double precision simptc(numplt,numclu)
      integer clusid(numplt)
      integer nabor(numplt)
 
! passed back
 
      double precision pltsil(numplt)
      double precision totsil 
 
! local
 
      double precision maxsim
      double precision a,b
 
      do i=1,numplt
        maxsim = 0.0
        nabor(i) = clusid(i)
        do j=1,numclu
          if (j .eq. clusid(i)) cycle 
          if (simptc(i,j) .gt. maxsim) then
            maxsim = simptc(i,j)
            nabor(i) = j
          endif
        end do  
      end do   
 
      totsil = 0.0

      do i=1,numplt
        a = 1 - simptc(i,clusid(i))
        b = 1 - simptc(i,nabor(i))
        pltsil(i) = (b - a) / max(a,b)
        totsil = totsil + pltsil(i)
      end do   
 
      return
 
      end

      subroutine ptc(simptp,numplt,numclu,clusid,simptc,sumnum,sumden)
 
! passed in
 
      integer numplt
      integer numclu
      double precision simptp(numplt,numplt)
      integer clusid(numplt)
      double precision sumnum(numclu)
      integer sumden(numclu)
 
! passed back
 
      double precision simptc(numplt,numclu)
 
      do i=1,numplt
        do j=1,numclu
          sumnum(j) = 0.0
          sumden(j) = 0.0
        end do  
 
        do j=1,numclu
          do k=1,numplt
            if (i .eq. k) cycle 
            sumnum(clusid(k)) = sumnum(clusid(k)) + simptp(i,k) 
            sumden(clusid(k)) = sumden(clusid(k)) + 1
          end do   
        end do   
 
        do j=1,numclu
          simptc(i,j) = sumnum(j)/max(sumden(j),1)
        end do   
      end do   
 
      return
 
      end
