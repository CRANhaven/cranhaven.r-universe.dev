      subroutine gamma(clust,dist,sd,siz,bigsiz,nc,nd)

      integer siz
      integer bigsiz
      integer clust(siz)
      double precision dist(bigsiz)
      integer sd(bigsiz)
      integer nc
      integer nd

      integer pnt

      do i=1,siz-1
        do j=i+1,siz
          pnt = siz*(i-1) - i*(i-1)/2 + j -i
          if (clust(i) .eq. clust(j)) sd(pnt) = 1
        end do
      end do

      do i=1,(bigsiz-1)
        do j=(i+1),bigsiz
          if (sd(i) .eq. 1 .and. sd(j) .eq. 1) cycle
          if (sd(i) .ne. 1 .and. sd(j) .ne. 1) cycle
          if (sd(i) .eq. 1 .and. sd(j) .ne. 1) then
            if (dist(i) < dist(j)) then
              nc = nc + 1
            else 
              nd = nd + 1
            end if
          else if ((sd(i) .ne. 1) .and. (sd(j) .eq. 1)) then
            if (dist(i) > dist(j)) then
              nc = nc + 1
            else 
              nd = nd + 1
            end if
          end if 
        end do 
      end do

      return
          
      end
     
