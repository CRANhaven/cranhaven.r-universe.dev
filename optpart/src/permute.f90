      subroutine permute(class,pclass,numplt,tclass)

!* passed
 
      integer numplt
      integer class(numplt)
      integer pclass(numplt)
      integer tclass(numplt)
 
!* local
 
      integer pool
      integer index
      double precision unifrnd
 
      call rndstart()
 
      pool = numplt

      do i=1,numplt
        tclass(i) = class(i)
      end do   
 
      do i=1,numplt
        index = ceiling(unifrnd()*(pool))
        pclass(i) = tclass(index)
        tclass(index) = tclass(pool)
        pool = pool - 1
      end do    
 
      call rndend
 
      return
 
      end
