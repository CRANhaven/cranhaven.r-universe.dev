      subroutine clique(sim,ds,left,rows,cols,alphac,top,bottom,orig)
 
      integer rows
      integer cols
      double precision sim(cols,cols)
      integer ds(rows,cols)
      integer left(rows)
      double precision alphac
      integer top
      integer bottom
      integer orig
 
      integer point
     
!*************************** one ***************************
 
      top = 1
 
      do i=1,cols-1
        where (sim(i,i+1:cols) < alphac) ds(top,i+1:cols) = 1
        if (all(ds(top,:) .eq. 1)) then
          cycle
        endif
        if (any(ds(top,:) .eq. 1)) then
          left(top) = i
          top = top + 1
        endif
      end do   
 
      if (top .eq. 1) then
        return
      else
        orig = top - 1
      endif
 
!*************************** two **************************
 
      ds(top,left(1)) = 1
      ds(top,left(2)) = 1
 
      ds(top+1,:) = ds(2,:)
      ds(top+2,:) = ds(1,:)
      ds(top+3,:) = max(ds(1,:),ds(2,:))
      ds(top+1,left(1)) = 1
      ds(top+2,left(2)) = 1
 
      bottom = top + 3
      call collap(ds,top,bottom,rows,cols,orig)
 
      point = bottom 
 
      do i=3,orig
        do j=top,bottom
          if (point+2 > rows) then
            orig = -1
            return
          endif
          ds(point+1,:) = ds(j,:)
          ds(point+1,left(i)) = 1
          ds(point+2,:) = max(ds(i,:),ds(j,:))
          point = point + 2
        end do  
        top = bottom + 1
        bottom = point
        call collap(ds,top,bottom,rows,cols,orig)
        point = bottom
      end do   
 
      end


      subroutine collap(ds,top,bottom,rows,cols,orig)
 
      integer rows
      integer cols
      integer ds(rows,cols)
      integer top 
      integer bottom 
      integer orig
 
      integer point
      integer keeper
 
!****************************** one *************************
 
      keeper = 0
      point = bottom 
 
      outer: do i=top,bottom
        do j=top,i-1
          suma = sum(ds(i,:))
          sumb = sum(max(ds(i,:),ds(j,:)))
          if (all(ds(i,:)-ds(j,:) .eq. 0)) then
            cycle outer
          else if (suma .eq. sumb) then
            cycle outer
          endif
        end do   
 
        do j=i+1,bottom
          suma = sum(ds(i,:))
          sumb = sum(max(ds(i,:),ds(j,:))) 
          if (all(ds(i,:)-ds(j,:) .eq. 0)) then
            cycle
          else if (suma .eq. sumb) then
            cycle outer
          endif
        end do   
 
        point = point + 1
        ds(point,:) = ds(i,:)
        keeper = keeper + 1
      end do outer
 
!* collap ********************* two ******************************
 
      do i=1,keeper
        ds(orig+i,:) = ds(bottom+i,:)
      end do    
 
      top = orig + 1
      bottom = orig + keeper 
 
      return
 
      end
