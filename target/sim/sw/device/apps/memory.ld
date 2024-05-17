/* Copyright 2020 ETH Zurich and University of Bologna. */
/* Solderpad Hardware License, Version 0.51, see LICENSE for details. */
/* SPDX-License-Identifier: SHL-0.51 */

/* Defines the L2_ORIGIN variable */
L2_ORIGIN = 0x2F000000;
L2_LENGTH = 0x40000;

MEMORY
{
    L2 (rwxa) : ORIGIN = L2_ORIGIN, LENGTH = L2_LENGTH
}

