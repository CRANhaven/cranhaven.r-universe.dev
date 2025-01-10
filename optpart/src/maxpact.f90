      subroutine maxpact(sim,numplt,maxsiz,alphac,morf,     &
                 musuby,membry,numset,used,musubx,membrx,   &
                 mnsimi,maxpnt)
 
! passed in
 
      integer numplt
      integer maxsiz
      double precision sim(numplt,numplt)
      double precision alphac
      integer morf
 
! passed out
 
      double precision musuby(numplt,maxsiz)
      integer membry(numplt,maxsiz)
      integer numset
 
! scratch 
 
      integer used(numplt)
      integer maxpnt(numplt)
      integer membrx(numplt,numplt)
      double precision musubx(numplt,numplt)
      double precision mnsimi(numplt)

! local

      double precision maxsim
      double precision temsim
      double precision tmp
      double precision unifrnd
      integer numpnt
      integer flag
      double precision choice
      integer i,j,k
 
!* maxpact ********************* one *********************
      
      call rndstart()
 
      do i=1,numplt
        used = (/ (0,j=1,numplt) /)
        membrx(i,:) = (/ (0,j=1,numplt) /)
        musubx(i,:) = (/ (0,j=1,numplt) /)

        maxpnt(i) = 0
        used(i) = 1
        musubx(i,i) = 1.0
        mnsimi(1) = 0.0
        membrx(i,1) = i
 
        do j=2,maxsiz
          maxsim = 0.0
          numpnt = 0
          do k=1,numplt
            if (used(k) .eq. 1) cycle
            if (morf .eq. 1) then
              temsim = 0.0
              do l=1,numplt
                if (used(l) .eq. 1) then
                  temsim = temsim + sim(k,l)
                endif
              end do   
            else
              temsim = 1.0
              do l=1,numplt
                if (used(l) .eq. 1) then
                  temsim = min(temsim,sim(k,l))
                endif
              end do   
            endif
            if (temsim .gt. maxsim) then
              numpnt = 1
              maxpnt(1) = k
              maxsim = temsim
            else if ((temsim .eq. maxsim) .and. (maxsim .gt. 0.0) ) then
              numpnt = numpnt + 1
              maxpnt(numpnt) = k
            endif 
          end do    
 
          if (numpnt .gt. 1) then
            choice = 0.0
            do l=1,numpnt
              tmp = unifrnd()
              if (tmp .gt. choice) then
                choice = tmp
                maxpnt(1) = maxpnt(l)
              endif
            end do    
          endif
 
          used(maxpnt(1)) = 1
          if (morf .eq. 1) then
            mnsimi(j) = (((j-1)**2-(j-1))/2 * mnsimi(j-1) + maxsim) / ((j**2-j)/2)
          else
            mnsimi(j) = maxsim
          endif
          musubx(i,maxpnt(1)) = mnsimi(j)
          membrx(i,j) = maxpnt(1)
        end do   
      end do   
!
      call rndend()
!
!* maxpact ********************** two ********************************
!
      numset = 0
      do i=1,numplt
        flag = 0
        do 21 j=1,i-1
          do k=1,numplt
            if (musubx(i,k) .ge. alphac .and.             &
                musubx(j,k) .lt. alphac) then
              goto 21
            else if (musubx(i,k) .lt. alphac .and.        &
                     musubx(j,k) .ge. alphac) then
              goto 21
            endif
          end do    
          flag = 1
   21   end do 
        if (flag .eq. 0) then
          numset = numset + 1
          do j=1,maxsiz
            musuby(numset,j) = musubx(i,membrx(i,j))
            membry(numset,j) = membrx(i,j)
          end do    
        endif
      end do   
!
      return
!
      end
