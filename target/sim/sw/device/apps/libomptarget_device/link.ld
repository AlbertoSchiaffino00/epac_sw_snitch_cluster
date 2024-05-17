/* Copyright 2020 ETH Zurich and University of Bologna. */
/* Solderpad Hardware License, Version 0.51, see LICENSE for details. */
/* SPDX-License-Identifier: SHL-0.51 */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

/* Memory section should be provided in a separate, platform-specific */
MEMORY
{
  L2           : ORIGIN = 0x2f000000, LENGTH = 0x40000
}

SECTIONS
{
  debug_base = 0x0;
  msi_base = 0x00200000;
  clint_base = 0x02000000;
  plic_base = 0x0c000000;
  next_base = 0x40000000;
  vrp_base = 0x80000000;
  stx_ext_base = 0xc0000000;
  . = 0x20000000;
  /*  The AT keyword defines the LMA, i.e. where the section is loaded. We
      specify this as the first cluster's external address here for convenient
      ELF loading with one cluster; for multiple clusters, every individual L1
      needs should be preloaded with this section. */
  .l1 : AT(0x21000000) { *(.l1) }
  .noinit_l1 (NOLOAD) : { *(.noinit_l1) }
  bootrom_start = 0x2C000000; 
  l1_alloc_base = ALIGN(0x10);
  tcdm_start_address_reg = 0x20800000;
  tcdm_end_address_reg = 0x20800008;
  nr_cores_address_reg = 0x20800010;
  fetch_enable_reg = 0x20800018;
  scratch_reg = 0x20800020;
  wake_up_reg = 0x20800028;
  cycle_count_reg = 0x20800030;
  barrier_reg = 0x20800038;
  cluster_base_hart_id_reg = 0x20800040;
  ssr_config_reg = 0x204800;
  eoc_address = 0x2E000100;
  l2_size  = 32*1024*8;
  l2_start = 0x2F000000;
  l2_end   = l2_start + l2_size;
  . = 0x2F000000;
  
  /* Program code goes into L2 */
  .text :
  {
    . = ALIGN(4);
    *(.init)
    *(.text.init)
    *(.text.startup)
    *(.text)
    *(.text*)
    *(.text)
    . = ALIGN(4);
    _etext = .;
  } >L2

  /* By default, constant data goes into L2, right after code section */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >L2

  /* HTIF section for FESVR */
  .htif         : { } >L2

  /* Thread Local Storage sections */
  .tdata    :
  {
    __tdata_start = .;
    *(.tdata .tdata.* .gnu.linkonce.td.*)
    __tdata_end = .;
  } >L2
  .tbss :
  {
    __tbss_start = .;
    *(.tbss .tbss.* .gnu.linkonce.tb.*)
    *(.tcommon)
    __tbss_end = .;
  } >L2

  /* Cluster Local Storage sections */
  .cdata    :
  {
    __cdata_start = .;
    *(.cdata .cdata.*)
    __cdata_end = .;
  } >L2
  .cbss :
  {
    __cbss_start = .;
    *(.cbss .cbss.*)
    __cbss_end = .;
  } >L2

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* small data section that can be addressed through the global pointer */
  .sdata          :
  {
    __SDATA_BEGIN__ = .;
    __global_pointer$ = . + 0x7f0;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata .srodata.*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  } >L2

  /* Initialized data sections goes into L2 */
  .data :
  {
    __DATA_BEGIN__ = .;
    *(.data .data.* .gnu.linkonce.d.*)
    SORT(CONSTRUCTORS)
  } >L2
  _edata = .; PROVIDE (edata = .);

  /* small bss section */
  . = .;
  __bss_start = .;
  .sbss           :
  {
    *(.dynsbss)
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  } >L2

  /* Uninitialized data section */
  .bss            :
  {
   *(.dynbss)
   *(.bss .bss.* .gnu.linkonce.b.*)
   *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections. */
   . = ALIGN(. != 0 ? 32 / 8 : 1);
  } >L2
  . = ALIGN(32 / 8);
  . = SEGMENT_START("ldata-segment", .);
  . = ALIGN(32 / 8);
  __BSS_END__ = .;
  __bss_end = .;
  _end = .; PROVIDE (end = .);

  /* Uninitialized data section in L2 */
  .dram :
  {
    *(.dram)
    _edram = .;
  } >L2

  __uart = 0x2002000;
}
