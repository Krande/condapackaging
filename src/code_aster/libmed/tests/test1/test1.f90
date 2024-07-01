program hello
    implicit none
#include <med.hf>
    character(len=255) :: kfic
    character(len=200) :: nofimd
    character(len=200) :: nom  ! Add this line to declare 'nom'
    integer :: fid
    integer :: acces
    integer :: major
    integer :: minor
    integer :: rel
    integer :: cret
    character(len=1) :: dummy  ! Dummy variable to capture Enter key press

    kfic = 'fort.80'
    ! Initialize the variable 'nofimd'
    nom = kfic(1:200)
    acces = 3
    cret = 0

    major = 3
    minor = 3
    rel = 1

    ! Print diagnostic message
    print *, 'Before calling subroutine'
    ! Wait for user to press enter
!    print *, 'Press enter to continue'
!    read(*, '(A)') dummy

    ! Call the subroutine
    call mfivop(fid, nom, acces, major, minor, rel, cret)

    ! Print diagnostic message
    print *, 'Success! After calling subroutine'
end program hello
