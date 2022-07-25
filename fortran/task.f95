
subroutine help()
   print '("Usage :-")'
   print '("$ ./task add 2 hello world    # Add a new item with priority 2 and text ""hello world"" to the list")'
   print '("$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order")'
   print '("$ ./task del INDEX            # Delete the incomplete item with the given index")'
   print '("$ ./task done INDEX           # Mark the incomplete item with the given index as complete")'
   print '("$ ./task help                 # Show usage")'
   print '("$ ./task report               # Statistics")'
end subroutine help


program main
implicit none
   integer::argc, ix
   character(len=6), dimension(:), allocatable::argv
   character(len=100), dimension(:), allocatable::file_data
   character(len=6) :: primaryArg = ''

   integer :: stat
   character(len=200) :: line
   logical :: file_exists


   argc = command_argument_count()
   allocate(argv(argc))

   do ix = 1, argc
      call get_command_argument(ix,argv(ix))
   end do
   primaryArg = argv(1)

   if (primaryArg == 'ls') then
      ! call add(argc,argv)
   else if (primaryArg == 'add') then
      if (argc > 2) then
         if (argv(2) >= '0') then
            INQUIRE(FILE="task.txt", EXIST=file_exists)
            if(file_exists) then
               open (1, file='task.txt', status='old')
               ix = 1
               allocate(file_data(100))
               do
                  read(1, '(A)', IOSTAT=stat) line
                  if (IS_IOSTAT_END(stat)) exit
                  file_data(ix) = trim(line)
                  ix = ix + 1
               end do
               ix = 1
               do ix = 1, len(file_data)
                  if (argv(2) .lt. line .or. len(argv(2)) .lt. len(line)) then
                  ! insert at ix index of file_data

                  stop
                  end if
               end do
            else
               open (1, file='task.txt', status='new')
            end if

            close (1)
         else
            print '("Priority cannot be negative")'
         end if
      else
         print '("Error: Missing tasks string. Nothing added!")'
      end if
   else if (primaryArg == 'del') then
      ! call del(argc,argv)
   else if (primaryArg == 'done') then
      ! call done(argc,argv)
   else if (primaryArg == 'report') then
      ! call report()
   else
      call help()
   endif

   deallocate(argv)

end program main
