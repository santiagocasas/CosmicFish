!----------------------------------------------------------------------------------------
!
! This file is part of CosmicFish.
!
! Copyright (C) 2015-2017 by the CosmicFish authors
!
! The CosmicFish code is free software;
! You can use it, redistribute it, and/or modify it under the terms
! of the GNU General Public License as published by the Free Software Foundation;
! either version 3 of the License, or (at your option) any later version.
! The full text of the license can be found in the file LICENSE at
! the top level of the CosmicFish distribution.
!
!----------------------------------------------------------------------------------------

program test_fisher_cls_deriv_calc

    use precision
    use cosmicfish_types
    use init_from_file
    use ModelParams
    use AMLutils
    use IniFile
    use cosmicfish_camb_interface
    use Fisher_calculator_Cls

    implicit none

    Type(CAMBparams)       :: P
    Type(cosmicfish_params) :: FP
    character(LEN=Ini_max_string_len) paramfile

    integer  :: err, cl_dim, l_min, l_max
    real(dl), dimension(:,:,:), allocatable :: cl_initial, cl_derivative, cl_error
    integer :: num_param
    real(dl), dimension(:), allocatable :: param_array
    real(dl) :: initial_step

    integer, parameter :: param_test = 1

    ! read the parameter file name:
    paramfile = ''
    if (GetParamCount() /= 0)  paramfile = GetParam(1)
    if (paramfile == '') stop 'No parameter input file'
    ! initialize parameters:
    call init_cosmicfish_from_file( P, FP, paramfile )
    ! get the number of parameters:
    call num_param_Fisher(P, FP, num_param)
    ! allocate a parameter array:
    allocate( param_array(num_param) )
    ! write the parameters in the parameter array:
    call CAMB_params_to_params_array( P, FP, num_param, param_array )
    ! get the size of the cls covariance matrix:
    call dimension_cl_covariance( P, FP, cl_dim )

    ! decide l_min and l_max:
    l_min = 2
    l_max = 2500

    ! allocation:
    allocate( cl_initial( cl_dim, cl_dim, l_max-l_min+1 ), &
            & cl_derivative( cl_dim, cl_dim, l_max-l_min+1 ), &
            & cl_error( cl_dim, cl_dim, l_max-l_min+1 ) )

    call cl_covariance_out( P, FP, cl_dim, l_min, l_max, cl_initial, err )

    if ( err /= 0 ) stop 'Something went wrong with the computation of the fiducial model'

    initial_step = param_array(param_test)*0.03_dl

    call cls_derivative( P, FP, param_test, &
        & cl_initial, cl_derivative, cl_error, &
        & initial_step, &
        & cl_dim, l_min, l_max, num_param, &
        & err )

    if ( err /= 0 ) stop 'Something went wrong with the computation of the cls derivative'

    ! save to file:
    call save_cl_covariance_to_file( cl_derivative, cl_dim, l_min, l_max, filename='output' )

    ! all the successful test should return the following.
    stop 100

end program test_fisher_cls_deriv_calc
