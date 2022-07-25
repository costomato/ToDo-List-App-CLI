
program main
implicit none
   integer:: ix
   
   ! infinite loop
   do
      ix = ix + 1
      print*, ix
      if (ix .eq. 120) then
         stop
      end if
   end do


end program main
