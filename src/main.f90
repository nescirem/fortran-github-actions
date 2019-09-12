!**************************************
!> Author: nescirem
!  Created: 09/12/2019
!
!  Hello World!
!

      program main

        use, intrinsic :: iso_fortran_env, only: output_unit
        implicit none

        write ( output_unit,"(G0)" ) "Hello World!"

      end program main
