      subroutine optpart(simptp,simptc,simctc,simrat,cardin,    &
                        numplt,numclu,musubx,final,clusid,      &
                        maxdmu,maxitr,numitr,dratio,maxdif,     &
                        dltamu,pltdif)
!
!* passed in/out
!
      integer numplt                            ! number of plots
      integer numclu                            ! number of clusters
      integer maxitr
      integer numitr
      double precision simptp(numplt,numplt)    ! similarity plot-to-plot
      double precision simptc(numplt,numclu)    ! similarity of plot-to-cluster
      double precision simctc(numclu,numclu)    ! similarity of cluster-to-cluster
      double precision simrat(maxitr)           ! overall similarity ratio
      double precision cardin(numclu)           ! total membership of cluster
      double precision musubx(numplt,numclu)    ! membership of plot in cluster
      double precision final(numplt,numclu)
      integer clusid(numplt)                    ! cluster ID for plot
      double precision maxdmu                   ! maximum membership transfer
      double precision dratio(numclu,numclu)
      double precision maxdif(numclu,numclu)
      double precision dltamu(numclu,numclu)
      integer pltdif(numclu,numclu)
!
!* common numer 
!
      double precision sumswi
      double precision sumsbt
      double precision sumcwi
      double precision sumcbt
!
      common / numer /  sumswi,sumsbt,sumcwi,sumcbt
!  
      character rorc*1
!
!* local
!
      double precision ratiod
      double precision maxsim
      double precision tmprat
!
!*********** initialize cluster membership array *******************
!
      do i=1,numplt
        if (clusid(i) .gt. 0) then
          musubx(i,clusid(i)) = 1.0
          do j=1,numclu
            if (j .eq. clusid(i)) cycle 
            musubx(i,j) = 0.0
          end do  
        endif
      end do
!
      rorc = 'R'
!
!********************************** three ******************************
!
      outer: do i=1,maxitr         
        do        
          call calcar(musubx,cardin,numplt,numclu)
          call fclctc(simptp,simctc,numplt,numclu,musubx)
          call ratio(simctc,numclu,cardin,tmprat)
          simrat(i) = tmprat
          if (i .eq. 1) then
            ratiod = 0.0
          else
            ratiod = simrat(i) - simrat(i-1)
          endif
!
          if (ratiod .gt. 0.0 .or. i .eq. 1) then
            do j=1,numplt
              do k=1,numclu
                final(j,k) = musubx(j,k)
              end do  
            end do   
            exit
          else if (ratiod .le. 0 .and. i .gt. 1) then
            if (rorc .eq. 'R') then
              rorc = 'C'
            else if (rorc .eq. 'C') then
              rorc = 'U'
            else if (rorc .eq. 'U') then
              numitr = i
              exit outer 
            endif
            do j=1,numplt
              do k=1,numclu
                musubx(j,k) = final(j,k)
              end do   
            end do   
          endif
        end do
!
        numitr = maxitr
!
        call fclptc(simptp,simptc,numplt,numclu,musubx,cardin)
        call deltam(simptc,musubx,numplt,numclu,maxdmu,cardin,rorc,  &
                    dratio,maxdif,dltamu,pltdif)
      end do outer 
! 
!* altfcl ****************************** five *******************************
!
      call fclctc(simptp,simctc,numplt,numclu,musubx)
!
      do i=1,numplt
        maxsim = 0.0
        do j=1,numclu
          if (musubx(i,j) .gt. maxsim) clusid(i) = j
        end do  
      end do  
!
      end
!
!************************ subroutine fclctc *************************
!
      subroutine fclctc(simptp,simctc,numplt,numclu,musubx)
!
!* passed
!
      integer numplt
      integer numclu
      double precision simptp(numplt,numplt)
      double precision simctc(numclu,numclu)
      double precision musubx(numplt,numclu)
!
!* local
!
      double precision weight
      double precision sumnum
      double precision sumden
!
!******************************** one **********************************
!
      do i=1,numclu
        do j=i,numclu
          simctc(i,j) = 0.0
          sumnum = 0.0
          sumden = 0.0
          do k=1,numplt
            if (musubx(k,i) .le. 0.0) cycle   
            do l=1,numplt
              if (k .eq. l) cycle   
              if (musubx(l,j) .le. 0.0) cycle   
              weight = min(musubx(k,i),musubx(l,j))
              sumnum = sumnum + (simptp(k,l) * weight)
              sumden = sumden + weight
            end do   
          end do    
          if (sumden .lt. 0.01) then
            simctc(i,j) = 0.0
          else
            simctc(i,j) = sumnum /sumden
          endif
          simctc(j,i) = simctc(i,j)
        end do   
      end do   
!
      return
!
      end
!
!* dsv_fcl ******************** subroutine fclptc ***************************
!
      subroutine fclptc(simptp,simptc,numplt,numclu,musubx,cardin)
!
!* passed
!
      integer numplt
      integer numclu
      double precision simptp(numplt,numplt)
      double precision simptc(numplt,numclu)
      double precision musubx(numplt,numclu)
      double precision cardin(numclu)
!
!* local
!
      double precision sumnum
      double precision sumden
!
!* dsv_fcl/fclptc ****************** one ************************************
!
      do i=1,numplt
        do j=1,numclu
          if (cardin(j) .eq. 0.0) then
            simptc(i,j) = 0.0
          else
            sumnum = 0.0
            sumden = 0.0
            do k=1,numplt
              if (musubx(k,j) .le. 0.0) cycle   
              if (i .eq. k) cycle   
              sumnum = sumnum + simptp(i,k) * musubx(k,j)
              sumden = sumden + musubx(k,j)
            end do  
            if (sumden .le. 0.0) sumden = 1.0
            simptc(i,j) = sumnum / sumden
          endif
        end do   
      end do   
!
      return

      end
!
!* dsv_fcl ********* subtoutine ratio *********************************
!
      subroutine ratio(simctc,numclu,cardin,simrat)
!
!* passed
!
      integer numclu
      double precision simctc(numclu,numclu)
      double precision cardin(numclu)
      double precision simrat
!
!* common numer
!
      double precision sumswi
      double precision sumsbt
      double precision sumcwi
      double precision sumcbt
!
      common / numer /  sumswi,sumsbt,sumcwi,sumcbt
!
!
!* local
!
      double precision weight
      double precision simwis
      double precision simbts
!
!* dsv_fcl/ratio ************** one **********************************
!          
      sumswi = 0.0
      sumsbt = 0.0
      sumcwi = 0.0
      sumcbt = 0.0
!
      do i=1,numclu
      if (cardin(i) .eq. 0.0) cycle   
        do j=i,numclu
          if (cardin(j) .eq. 0.0) cycle   
          if (i .eq. j) then
            weight = (cardin(i)**2-cardin(i))/2
            sumswi = sumswi + weight * simctc(i,i)
            sumcwi = sumcwi + weight
          else
            weight = cardin(i) * cardin(j)
            sumsbt = sumsbt + weight * simctc(i,j)
            sumcbt = sumcbt + weight
          endif
        end do  
      end do   
!
      simwis = sumswi / sumcwi
      simbts = sumsbt / sumcbt
      simrat = simwis / simbts
!
      return
!
      end
!
!* dsv_fcl ************ subroutine deltam ****************************
!
      subroutine deltam(simptc,musubx,numplt,numclu,maxdmu,cardin,    &
                        rorc,dratio,maxdif,dltamu,pltdif)
!
!* passed
!
      integer numplt
      integer numclu
      double precision simptc(numplt,numclu)
      double precision musubx(numplt,numclu)
      double precision maxdmu
      double precision cardin(numclu)
      character rorc*1
      double precision dratio(numclu,numclu)
      double precision maxdif(numclu,numclu)
      double precision dltamu(numclu,numclu)
      integer pltdif(numclu,numclu)
!
!* common numer
!
      double precision sumswi
      double precision sumsbt
      double precision sumcwi
      double precision sumcbt
!
      common / numer /  sumswi,sumsbt,sumcwi,sumcbt
!
!* local
!
      double precision dmusub
      double precision newswi
      double precision newsbt
      double precision newcwi
      double precision newcbt
      double precision ratio
      double precision musj,musk
!
      double precision tmpmax
      integer pltnum
      double precision summu
!
!* dsv_fcl/deltam ********** one **********************************
!
      ratio = (sumswi/sumcwi) / (sumsbt/sumcbt)
!
      do i=1,numclu
        do j=1,numclu
          maxdif(i,j) = 0.0
          dltamu(i,j) = 0.0
          pltdif(i,j) = 0
        end do 
      end do   
!
      do i=1,numplt
        do j=1,numclu
          musj = musubx(i,j)
          if (musj .le. 0) cycle 
          do k=1,numclu
            dratio(j,k) = 0.0
            musk = musubx(i,k)
            if (j .eq. k) cycle 
            if (musk .lt. 0) cycle 
            dmusub = min(musj,1.0-musk) * maxdmu
            if (dmusub .gt. 0) then
              newswi = sumswi-((simptc(i,j)*(cardin(j)-musj))*dmusub) &
                           +((simptc(i,k)*(cardin(k)-musk))*dmusub)
              newcwi = sumcwi - ((cardin(j)-musj)*dmusub)             &
                           + ((cardin(k)-musk)*dmusub)
              newsbt = sumsbt+((simptc(i,j)*(cardin(j)-musj))*dmusub) &
                           -((simptc(i,k)*(cardin(k)-musk))*dmusub)
              newcbt = sumcbt + ((cardin(j)-musj)*dmusub)             &
                           - ((cardin(k)-musk)*dmusub)
              dratio(j,k) = ((newswi/newcwi) / (newsbt/newcbt)) /     &
                                 ratio
              if (dratio(j,k) .gt. maxdif(j,k)) then
                maxdif(j,k) = dratio(j,k)
                pltdif(j,k) = i
                dltamu(j,k) = dmusub
              endif
            endif
          end do  
        end do  
      end do    
!
!* dsv_fcl/deltam ************** two **********************************
!
      tmpmax = 1.0
      numrow = 0
      numcol = 0
!
      do 
        do i=1,numclu
          do j=1,numclu
            if (i .eq. j) cycle 
            if (maxdif(i,j) .gt. tmpmax) then
              tmpmax = maxdif(i,j)
              numrow = i
              numcol = j
            endif
          end do   
        end do   
!
        if (tmpmax .gt. 1.0) then
          pltnum = pltdif(numrow,numcol)
          dmusub = min(musubx(pltnum,numrow),1.0-musubx(pltnum,numcol), &
              dltamu(numrow,numcol)) * maxdmu
          musubx(pltnum,numrow) = musubx(pltnum,numrow) - dmusub
          musubx(pltnum,numcol) = musubx(pltnum,numcol) + dmusub
          if (rorc .eq. 'C') then
            do i=1,numclu
              maxdif(numrow,i) = 0.0
              maxdif(i,numrow) = 0.0
              maxdif(i,numcol) = 0.0
              maxdif(numcol,i) = 0.0
            end do   
          else if (rorc .eq. 'U') then
            tmpmax = 1.0
            exit      
          else
            maxdif(numrow,numcol) = 0.0
            maxdif(numcol,numrow) = 0.0
          endif
          tmpmax = 1.0
        else
          exit
        endif
      end do
!
      do i=1,numplt
        summu = 0.0
        do j=1,numclu
          summu = summu + musubx(i,j)
        end do   
      end do  
!
      return
!
      end
!
!* dsv_fcl ******************** subroutine calcar ******************
!
      subroutine calcar(musubx,cardin,numplt,numclu)
!
!* passed
!
      integer numplt
      integer numclu
      double precision musubx(numplt,numclu)
      double precision cardin(numclu)
!
!* local
!
!     double precision total
!
!* dsv_fcl/calcar ************** one ******************************
!
      do i=1,numclu
        cardin(i) = 0.0
      end do   
!
      do i=1,numplt
        do j=1,numclu
          cardin(j) = cardin(j) + musubx(i,j)
!         total = total + musubx(i,j)
        end do   
      end do   
!
      return
!
      end

