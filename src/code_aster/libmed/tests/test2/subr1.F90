module subroutines
    implicit none

contains
    subroutine call_me(fid, name, acces, major, minor, rel, cret)
        #include <med.hf>
        character(len=200) :: name  ! Add this line to declare 'nom'
        integer :: fid
        integer :: acces
        integer :: major
        integer :: minor
        integer :: rel
        integer :: cret
        character(len=1) :: dummy  ! Dummy variable to capture Enter key press

        ! Print diagnostic message
        print *, 'Before calling subroutine'
        ! Wait for user to press enter
    !    print *, 'Press enter to continue'
    !    read(*, '(A)') dummy

        ! Call the subroutine
        call mfivop(fid, name, acces, major, minor, rel, cret)
        ! raise an error if cret is not 0 and exit with non-zero status
        if (cret /= 0) then
            print *, 'Error calling mfivop'
            stop
        end if
        ! Print diagnostic message
        print *, 'Success! After calling subroutine'

    end subroutine call_me
end module subroutines
