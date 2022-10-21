\m4_TLV_version 1d: tl-x.org
\SV
   // /====================\
   // | DAY5 LAB WORK - RISCV 3 CYCLE CPU  
   // \====================/
   // This code can be found in: https://github.com/stevehoover/RISC-V_MYTH_Workshop
   
   m4_include_lib(['https://raw.githubusercontent.com/sunnyraj10411/RISC-V/main/risc_v_shell_lib.tlv'])

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
                   

localparam SHIFT = 5;                   
localparam NODES = 2**SHIFT;  //32 nodes in the current design
localparam M_SIZE = NODES*NODES;
//localparam M_SIZE = 10;                   
//localparam Y_SIZE = 10;     
                   
                   
\TLV cpu_viz(@_stage)
   m4_ifelse_block(m4_sp_graph_dangerous, 1, [''], ['
   |cpu
      // for pulling default viz signals into CPU
      // and then back into viz
      @0
         $ANY = /top|cpuviz/defaults<>0$ANY;
         `BOGUS_USE($dummy)
         /xreg[31:0]
            $ANY = /top|cpuviz/defaults/xreg<>0$ANY;
         /dmem[15:0]
            $ANY = /top|cpuviz/defaults/dmem<>0$ANY;
         ///gmemx[X_SIZE-1:0]
         //   /gmemy[Y_SIZE-1:0]
         //      $ANY = /top|cpuviz/defaults/gmemx/gmemy<>0$ANY;
         /smem[M_SIZE-1:0]
         ///smem[1024:0]
            $ANY = /top|cpuviz/defaults/smem<>0$ANY;
   // String representations of the instructions for debug.
   \SV_plus
      logic [40*8-1:0] instr_strs [0:M4_NUM_INSTRS];
      assign instr_strs = '{m4_asm_mem_expr "END                                     "};
   |cpuviz
      @1
         /imem[m4_eval(M4_NUM_INSTRS-1):0]  // TODO: Cleanly report non-integer ranges.
            $instr[31:0] = /top|cpu/imem<>0$instr;
            $instr_str[40*8-1:0] = *instr_strs[imem];
            \viz_alpha
               renderEach: function() {
                  // Instruction memory is constant, so just create it once.
                  if (!global.instr_mem_drawn) {
                     global.instr_mem_drawn = [];
                  }
                  if (!global.instr_mem_drawn[this.getIndex()]) {
                     global.instr_mem_drawn[this.getIndex()] = true;
                     let instr_str = '$instr_str'.asString() + ": " + '$instr'.asBinaryStr(NaN);
                     this.getCanvas().add(new fabric.Text(instr_str, {
                        top: 18 * this.getIndex(),  // TODO: Add support for '#instr_mem'.
                        left: -580,
                        fontSize: 14,
                        fontFamily: "monospace"
                     }));
                  }
               }


      @0
         /defaults
            {$is_lui, $is_auipc, $is_jal, $is_jalr, $is_beq, $is_bne, $is_blt, $is_bge, $is_bltu, $is_bgeu, $is_lb, $is_lh, $is_lw, $is_lbu, $is_lhu, $is_sb, $is_sh, $is_sw} = '0;
            {$is_addi, $is_slti, $is_sltiu, $is_xori, $is_ori, $is_andi, $is_slli, $is_srli, $is_srai, $is_add, $is_sub, $is_sll, $is_slt, $is_sltu, $is_xor} = '0;
            {$is_srl, $is_sra, $is_or, $is_and, $is_csrrw, $is_csrrs, $is_csrrc, $is_csrrwi, $is_csrrsi, $is_csrrci} = '0;
            {$is_load, $is_store} = '0;

            $valid               = 1'b1;
            $rd[4:0]             = 5'b0;
            $rs1[4:0]            = 5'b0;
            $rs2[4:0]            = 5'b0;
            $src1_value[31:0]    = 32'b0;
            $src2_value[31:0]    = 32'b0;

            $result[31:0]        = 32'b0;
            $pc[31:0]            = 32'b0;
            $imm[31:0]           = 32'b0;

            $is_s_instr          = 1'b0;

            $rd_valid            = 1'b0;
            $rs1_valid           = 1'b0;
            $rs2_valid           = 1'b0;
            $rf_wr_en            = 1'b0;
            $rf_wr_index[4:0]    = 5'b0;
            $rf_wr_data[31:0]    = 32'b0;
            $rf_rd_en1           = 1'b0;
            $rf_rd_en2           = 1'b0;
            $rf_rd_index1[4:0]   = 5'b0;
            $rf_rd_index2[4:0]   = 5'b0;

            $ld_data[31:0]       = 32'b0;
            $imem_rd_en          = 1'b0;
            $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = {M4_IMEM_INDEX_CNT{1'b0}};
            
            /xreg[31:0]
               $value[31:0]      = 32'b0;
               $wr               = 1'b0;
               `BOGUS_USE($value $wr)
               $dummy[0:0]       = 1'b0;
            /dmem[15:0]
               $value[31:0]      = 32'0;
               $wr               = 1'b0;
               `BOGUS_USE($value $wr) 
               $dummy[0:0]       = 1'b0;
               
            ///gmemx[X_SIZE-1:0]
            //   /gmemy[Y_SIZE-1:0]
            //      $value[31:0]      = 32'0;
            //      $wr               = 1'b0;
            //      `BOGUS_USE($value $wr)
            //      $dummy[0:0]       = 1'b0;
                  
            ///smem[M_SIZE-1:0]
            /smem[1024:0]
               $value[31:0]      = 32'0;
               $wr               = 1'b0;
               `BOGUS_USE($value $wr) 
               $dummy[0:0]       = 1'b0;
               
            
            `BOGUS_USE($is_lui $is_auipc $is_jal $is_jalr $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_lb $is_lh $is_lw $is_lbu $is_lhu $is_sb $is_sh $is_sw)
            `BOGUS_USE($is_addi $is_slti $is_sltiu $is_xori $is_ori $is_andi $is_slli $is_srli $is_srai $is_add $is_sub $is_sll $is_slt $is_sltu $is_xor)
            `BOGUS_USE($is_srl $is_sra $is_or $is_and $is_csrrw $is_csrrs $is_csrrc $is_csrrwi $is_csrrsi $is_csrrci)
            `BOGUS_USE($is_load $is_store)
            `BOGUS_USE($valid $rd $rs1 $rs2 $src1_value $src2_value $result $pc $imm)
            `BOGUS_USE($is_s_instr $rd_valid $rs1_valid $rs2_valid)
            `BOGUS_USE($rf_wr_en $rf_wr_index $rf_wr_data $rf_rd_en1 $rf_rd_en2 $rf_rd_index1 $rf_rd_index2 $ld_data)
            `BOGUS_USE($imem_rd_en $imem_rd_addr)
            //`BOGUS_USE($is_g_instr $is_gi_instr $is_gr_instr)
 
            //`BOGUS_USE($imem_rd_en $imem_rd_addr)
            
            $dummy[0:0]          = 1'b0;
      @_stage
         $ANY = /top|cpu<>0$ANY;
         
         /xreg[31:0]
            $ANY = /top|cpu/xreg<>0$ANY;
            `BOGUS_USE($dummy)
         
         /dmem[15:0]
            $ANY = /top|cpu/dmem<>0$ANY;
            `BOGUS_USE($dummy)
            
         /*
         /gmemx[X_SIZE-1:0]
             /gmemy[Y_SIZE-1:0]
               $ANY = /top|cpu/gmemx/gmemy<>0$ANY;
               `BOGUS_USE($dummy)
         */
         
         
         ///smem[M_SIZE-1:0]
         /smem[1023:0]
            $ANY = /top|cpu/smem<>0$ANY;
            `BOGUS_USE($dummy)
            

         // m4_mnemonic_expr is build for WARP-V signal names, which are slightly different. Correct them.
         m4_define(['m4_modified_mnemonic_expr'], ['m4_patsubst(m4_mnemonic_expr, ['_instr'], [''])'])
         $mnemonic[10*8-1:0] = m4_modified_mnemonic_expr $is_load ? "LOAD      " : $is_store ? "STORE     " : "ILLEGAL   ";
         \viz_alpha
            //
            renderEach: function() {
               debugger;
               //
               // PC instr_mem pointer
               //
               let $pc = '$pc';
               let color = !('$valid'.asBool()) ? "gray" :
                                                  "blue";
               let pcPointer = new fabric.Text("->", {
                  top: 18 * ($pc.asInt() / 4),
                  left: -600,
                  fill: color,
                  fontSize: 14,
                  fontFamily: "monospace"
               });
               //
               //
               // Fetch Instruction
               //
               // TODO: indexing only works in direct lineage.  let fetchInstr = new fabric.Text('|fetch/instr_mem[$Pc]$instr'.asString(), {  // TODO: make indexing recursive.
               //let fetchInstr = new fabric.Text('$raw'.asString("--"), {
               //   top: 50,
               //   left: 90,
               //   fill: color,
               //   fontSize: 14,
               //   fontFamily: "monospace"
               //});
               //
               // Instruction with values.
               //
               let regStr = (valid, regNum, regValue) => {
                  return valid ? `r${regNum} (${regValue})` : `rX`;
               };
               let srcStr = ($src, $valid, $reg, $value) => {
                  return $valid.asBool(false)
                             ? `\n      ${regStr(true, $reg.asInt(NaN), $value.asInt(NaN))}`
                             : "";
               };
               let str = `${regStr('$rd_valid'.asBool(false), '$rd'.asInt(NaN), '$result'.asInt(NaN))}\n` +
                         `  = ${'$mnemonic'.asString()}${srcStr(1, '$rs1_valid', '$rs1', '$src1_value')}${srcStr(2, '$rs2_valid', '$rs2', '$src2_value')}\n` +
                         `      i[${'$imm'.asInt(NaN)}]`;
               let instrWithValues = new fabric.Text(str, {
                  top: 70,
                  left: 90,
                  fill: color,
                  fontSize: 14,
                  fontFamily: "monospace"
               });
               return {objects: [pcPointer, instrWithValues]};
            }
         //
         // Register file
         //
         /xreg[1:0]
            \viz_alpha
               initEach: function() {
                  let regname = new fabric.Text("Reg File", {
                        top: -20,
                        left: 367,
                        //left: 200,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                  let reg = new fabric.Text("", {
                     top: 18 * this.getIndex(),
                     left: 375,
                     //left: 200,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  return {objects: {regname: regname, reg: reg}};
               },
               renderEach: function() {
                  let mod = '$wr'.asBool(false);
                  let reg = parseInt(this.getIndex());
                  let regIdent = reg.toString();
                  let oldValStr = mod ? `(${'>>1$value'.asInt(NaN).toString()})` : "";
                  this.getInitObject("reg").setText(
                     regIdent + ": " +
                     '$value'.asInt(NaN).toString() + oldValStr);
                  this.getInitObject("reg").setFill(mod ? "blue" : "black");
               }
         /*      
         /gmemx[X_SIZE-1:0]         
            \viz_alpha
               initEach: function() {
                  let s1regname = new fabric.Text("SsRegs File", {
                        top: -10,
                        //left: 367,
                        left: 600,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                  let s1reg = new fabric.Text("", {
                     top: 18 * this.getIndex(),
                     //left: 375,
                     left: 600,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  return {objects: {s1regname: s1regname, s1reg: s1reg}};
               },
               renderEach: function() {
                  let mod = '/gmemy[0]$wr'.asBool(false);
                  let reg = parseInt(this.getIndex());
                  let regIdent = reg.toString();
                  let oldValStr = mod ? `(${'/gmemy[0]>>1$value'.asInt(NaN).toString()})` : "";
                  this.getInitObject("s1reg").setText(
                     regIdent + ": " + 2);
                     '/gmemy[0]$value'.asInt(NaN).toString() + oldValStr);
                  this.getInitObject("s1reg").setFill(mod ? "blue" : "black");
               }      
         */
               
         ///smem[M_SIZE-1:0]
         /smem[1023:0]
            \viz_alpha
               initEach: function() {
                  let sregname = new fabric.Text("SReg File", {
                        top: -20,
                        //left: 367,
                        left: 580,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                  let sreg = new fabric.Text("", {
                     top: 18 * this.getIndex(),
                     //left: 375,
                     left: 580,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  return {objects: {sregname: sregname, sreg: sreg}};
               },
               renderEach: function() {
                  let mod = '$wr'.asBool(false);
                  let reg = parseInt(this.getIndex());
                  let regIdent = reg.toString();
                  let oldValStr = mod ? `(${'>>1$value'.asInt(NaN).toString()})` : "";
                  this.getInitObject("sreg").setText(
                     regIdent + ": " +
                     '$value'.asInt(NaN).toString() + oldValStr);
                  this.getInitObject("sreg").setFill(mod ? "blue" : "black");
               }
         //
         // DMem
         //
         /dmem[15:0]
            \viz_alpha
               initEach: function() {
                  let smemname = new fabric.Text("Minis DMem", {
                        top: -20,
                        left: 460,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                  let smem = new fabric.Text("", {
                     top: 18 * this.getIndex(),
                     left: 468,
                     fontSize: 14,
                     fontFamily: "monospace"
                  });
                  return {objects: {smemname: smemname, smem: smem}};
               },
               renderEach: function() {
                  let mod = '$wr'.asBool(false);
                  let mem = parseInt(this.getIndex());
                  let memIdent = mem.toString();
                  let oldValStr = mod ? `(${'>>1$value'.asInt(NaN).toString()})` : "";
                  this.getInitObject("smem").setText(
                     memIdent + ": " +
                     '$value'.asInt(NaN).toString() + oldValStr);
                  this.getInitObject("smem").setFill(mod ? "blue" : "black");
               }
         
         /*
         /gmemx[X_SIZE-1:0]
            /gmemy[Y_SIZE-1:0]
               //\SV_plus
               //   always_ff @(posedge clk) begin
               //      \$display("Hi Sunny: \%2d",this.getIndex());
               //   end
               \viz_alpha
                  initEach: function() {
                     let gmemname = new fabric.Text("GMem", {
                           top: -20,
                           left: 550,
                           fontSize: 14,
                           fontFamily: "monospace"
                        });
                     let gmem = new fabric.Text("", {
                        top: 18 * this.getIndex(),
                        left: 558,
                        fontSize: 14,
                        fontFamily: "monospace"
                     });
                     return {objects: {gmemname: gmemname, gmem: gmem}};
                  },
                  renderEach: function() {
                     let mod = '$wr'.asBool(false);
                     let mem = parseInt(this.getIndex());
                     let memIdent = mem.toString();
                     let oldValStr = mod ? `(${'>>1$value'.asInt(NaN).toString()})` : "";
                     this.getInitObject("gmem").setText(
                        memIdent + ": " +
                        '$value'.asInt(NaN).toString() + oldValStr);
                     this.getInitObject("gmem").setFill(mod ? "blue" : "black");
                 }
         */
   '])
                   
                   
                   
                   
              
                   
\TLV graphMem(@_stage)
   // Data Memory
   @_stage
      /gmemx[X_SIZE-1:0]
         /gmemy[Y_SIZE-1:0]
            $wr = |cpu$gmem_wr_en && ((|cpu$gmem_addrx == #gmemx) && (|cpu$gmem_addry == #gmemy));
            $value[31:0] = |cpu$reset ?   32'0 :
                        $wr        ?   |cpu$gmem_wr_data :
                                       $RETAIN;             
      ?$gmem_rd_en
         $gmem_rd_data[31:0] = /gmemx[$gmem_addrx]/gmemy[$gmem_addry]>>1$value;
      `BOGUS_USE($gmem_rd_data)
 
 
 // A 2-rd 1-wr register file in |cpu that reads and writes in the given stages. If read/write stages are equal, the read values reflect previous writes.
// Reads earlier than writes will require bypass.
\TLV rf(@_rd, @_wr)
   // Reg File
   @_wr
      /xreg[31:0]
         $wr = |cpu$rf_wr_en && (|cpu$rf_wr_index != 5'b0) && (|cpu$rf_wr_index == #xreg);
         $value[31:0] = |cpu$reset ?   #xreg           :
                        $wr        ?   |cpu$rf_wr_data :
                                       $RETAIN;
   @_rd
      ?$rf_rd_en1
         $rf_rd_data1[31:0] = /xreg[$rf_rd_index1]>>m4_stage_eval(@_wr - @_rd + 1)$value;
      ?$rf_rd_en2
         $rf_rd_data2[31:0] = /xreg[$rf_rd_index2]>>m4_stage_eval(@_wr - @_rd + 1)$value;
      ?$rf_rd_en3
         $rf_rd_data3[31:0] = /xreg[$rf_rd_index3]>>m4_stage_eval(@_wr - @_rd + 1)$value;
      `BOGUS_USE($rf_rd_data1 $rf_rd_data2 $rf_rd_data3) 


// A data memory in |cpu at the given stage. Reads and writes in the same stage, where reads are of the data written by the previous transaction.
\TLV dmem(@_stage)
   // Data Memory
   @_stage
      /dmem[15:0]
         $wr = |cpu$dmem_wr_en && (|cpu$dmem_addr == #dmem);
         $value[31:0] = |cpu$reset ?   #dmem :
                        $wr        ?   |cpu$dmem_wr_data :
                                       $RETAIN;
                                  
      ?$dmem_rd_en
         $dmem_rd_data[31:0] = /dmem[$dmem_addr]>>1$value;
      `BOGUS_USE($dmem_rd_data)

 
 
      
\TLV smem(@_stage)
   // Data Memory
   @_stage
      /smem[M_SIZE-1:0]
      ///smem[1023:0]
         $wr = |cpu$smem_wr_en && (|cpu$smem_addr == #smem);
         $value[31:0] = |cpu$reset ?   32'0 :
                        $wr        ?   |cpu$smem_wr_data :
                                       $RETAIN;
                                  
      ?$smem_rd_en
         $smem_rd_data[31:0] = /smem[$smem_addr]>>1$value;
      `BOGUS_USE($smem_rd_data) 
                   
\TLV

   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program for MYTH Workshop to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  r10 (a0): In: 0, Out: final sum
   //  r12 (a2): 10
   //  r13 (a3): 1..10
   //  r14 (a4): Sum
   // 
   // External to function:
   m4_asm(ADD, r10, r0, r0)             // Initialize r10 (a0) to 0.
   // Function:
   m4_asm(ADD, r14, r10, r0)            // Initialize sum register a4 with 0x0
   m4_asm(ADDI, r12, r10, 1010)         // Store count of 10 in register a2.
   m4_asm(ADD, r13, r10, r0)            // Initialize intermediate sum register a3 with 0
   // Loop:
   m4_asm(ADD, r14, r13, r14)           // Incremental addition
   m4_asm(ADDI, r13, r13, 1)            // Increment intermediate register by 1
   m4_asm(BLT, r13, r12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   m4_asm(ADD, r10, r14, r0)            // Store final result to register a0 so that it can be read by main program
   m4_asm(SW, r0, r10, 10000)           // Store final result in memory address 0x10000
   m4_asm(LW, r17, r0, 10000)           // Load address 0x100000 in R17 register as final result
   
   
   m4_asm(EDGE, r10, r1, r2)            //adds the edge in r1 and r2, edge val in r10
   m4_asm(EDGE, r11, r1, r4)
   m4_asm(EDGE, r12, r1, r6)
   m4_asm(REDGE, r25, r1, r6)          //reads the edge and gets the value in r25
   //m4_asm(ADDI, r26, r14, 0)
   //m4_asm(ADDI, r26, r15, 0)
   // Optional:
   // m4_asm(JAL, r7, 00000000000000000000) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)
   

   

   |cpu
      @0
         $reset = *reset;
         $start = >>1$reset && !$reset;
         
         //PC IMPLEMENTATION 
         $pc[31:0] = >>1$reset ? 32'b0 :
                     >>3$valid_taken_br ? >>3$br_tgt_pc :
                     >>3$valid_load ? >>3$inc_pc :
                     >>3$valid_jump && >>3$is_jal ? >>3$br_tgt_pc : 
                     >>3$valid_jump && >>3$is_jalr ? >>3$jalr_tgt_pc :
                     >>1$inc_pc;
      @1   
         //PC Increment Stage 1
         $inc_pc[31:0] = $pc + 32'd4;
         //Instruction Memory Logic For memory instruction read enable,address and 
         //Memory Instruction Read Data to Decode Logic
         $imem_rd_en = !$reset;
         //print(M4_IMEM_INDEX_CNT);
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
         $instr[31:0] = $imem_rd_data[31:0];
         
         //Decode Logic - Instruction Decode
         // I - Type Instructions
         $is_i_instr = $instr[6:2] ==? 5'b0000x || 
                       $instr[6:2] ==? 5'b001x0 || 
                       $instr[6:2] ==? 5'b11001;
         // R - Type Instructions
         $is_r_instr = $instr[6:2] ==? 5'b011x0 || 
                       $instr[6:2] ==? 5'b01011 || 
                       $instr[6:2] ==? 5'b10100;
         // S - Type Instructions
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         // J - Type Instructions
         $is_j_instr = $instr[6:2] ==? 5'b11011;
         // U - Type Instructions
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         // B - Type Instructions
         $is_b_instr = $instr[6:2] ==? 5'b11000;
         
         // G - Type Instructions
         $is_gr_instr = $instr[6:2] ==? 5'b00010;
         $is_gi_instr = $instr[6:2] ==? 5'b01010;
         //$is_gi_instr = $instr[6:2] ==? 5'b000100;
         //$is_gr_instr = $instr[6:2] ==? 5'b000101;
         
         
         //Immediate Type
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20]} :
                      $is_gi_instr ? { {21{$instr[31]}}, $instr[30:20]} :
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7]} :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
                      $is_u_instr ? {$instr[31:12], 12'b0} :
                      $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0} :
                      32'b0;
         
         //Other Instruction Fields
         $rs2_valid    = $is_r_instr || $is_s_instr || $is_b_instr || $is_gr_instr;
         $rs1_valid    = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr || $is_gr_instr || $is_gi_instr;
         $rd_valid     = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr || $is_gr_instr || $is_gi_instr;
         $funct3_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr || $is_gr_instr || $is_gi_instr;
         $funct7_valid = $is_r_instr || $is_gr_instr;
         
         $opcode[6:0] = $instr[6:0];
         ?$rs2_valid
            $rs2[4:0]    = $instr[24:20];
         ?$rs1_valid
            $rs1[4:0]    = $instr[19:15];
         ?$rd_valid
            $rd[4:0]     = $instr[11:7];
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12];
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25];
         
      @2
         //Decoding Instructions 
         $dec_bits[10:0] = {$funct7[5] ,$funct3, $opcode};
         //Branch Instructions 
         //BEQ - Branch on equal 
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         //BNE - Branch on not equal
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         //BLT - Branch on less than
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         //BGE - Branch on greater than
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         //BLTU - Branch on less than equal
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         //BGEU - Branch on greater than equal
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         
         //ADD Instructions 
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         $is_add  = $dec_bits ==? 11'b0_000_0110011;
         
         //Subtract Instructions
         $is_sltiu  = $dec_bits ==? 11'bx_011_0010011;
         $is_xori   = $dec_bits ==? 11'bx_100_0010011;
         $is_ori    = $dec_bits ==? 11'bx_110_0010011;
         $is_andi   = $dec_bits ==? 11'bx_111_0010011;
         $is_slli   = $dec_bits ==? 11'b0_001_0010011;
         $is_srli   = $dec_bits ==? 11'b0_101_0010011;
         $is_sral   = $dec_bits ==? 11'b1_101_0010011;
         $is_sub    = $dec_bits ==? 11'b1_000_0110011;
         $is_sll    = $dec_bits ==? 11'b0_001_0110011;
         $is_slt    = $dec_bits ==? 11'b0_010_0110011;
         $is_sltu   = $dec_bits ==? 11'b0_011_0110011;
         $is_xor    = $dec_bits ==? 11'b0_100_0110011;
         $is_srl    = $dec_bits ==? 11'b0_101_0110011;
         $is_sra    = $dec_bits ==? 11'b1_101_0110011;
         $is_or     = $dec_bits ==? 11'b0_110_0110011;
         $is_and    = $dec_bits ==? 11'b0_111_0110011;
         
         //Miscellaneous Instructions 
         $is_lui    = $dec_bits ==? 11'bx_xxx_0110111;
         $is_auipc  = $dec_bits ==? 11'bx_xxx_0010111;
         $is_jal    = $dec_bits ==? 11'bx_xxx_1101111;
         $is_jalb   = $dec_bits ==? 11'bx_000_1100111;
         $is_sb     = $dec_bits ==? 11'bx_000_0100011;
         $is_sh     = $dec_bits ==? 11'bx_001_0100011;
         $is_sw     = $dec_bits ==? 11'bx_010_0100011;
         $is_slti   = $dec_bits ==? 11'bx_010_0010011;
         
         
         //Graph instructions 00010
         $is_edge = $dec_bits ==? 11'bx_000_0001011;
         $is_edgei = $dec_bits ==? 11'bx_000_0101011;
         $is_redge = $dec_bits ==? 11'bx_001_0001011;
         
         
         
         //LOAD INSTRUCTION - Making it one instruction instead of 5 as in ISA 
         $is_load   = $opcode == 7'b0000011;
         
         //Register File Reads
         //RS1 Reads
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;
         //RS2 Reads
         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         
          
         //Output of Register File Read to ALU as Input -- Also handling the READ AFTER WRITE ISSUE due to 
         // 3 cycle delay in instructions. REGISTER BYPASS LOGIC
         $src1_value[31:0] = (>>1$rf_wr_index == $rf_rd_index1) && >>1$rf_wr_en
                             ? >>1$result :
                             $rf_rd_data1;
         
         $src2_value[31:0] = (>>1$rf_wr_index == $rf_rd_index2) && >>1$rf_wr_en
                             ? >>1$result :
                             $rf_rd_data2;
                   
                   
         //sunny graph specific code here
         $rf_rd_en3 = $rd_valid;            
         $rf_rd_index3[4:0] = $rd;
         $graph_reg_value[31:0] = (>>1$rf_wr_index == $rf_rd_index3) && >>1$rf_wr_en
                             ? >>1$result :
                             $rf_rd_data3;
         
         //Branch Target for Immediate Instruction PC increment
         $br_tgt_pc[31:0] = $pc + $imm;
         
         //Jump Target for Immediate Instruction PC increment
         $jalr_tgt_pc[31:0] = $src1_value + $imm;
         
      @3   
         //BRANCHING Instructions 
         $taken_br = $is_beq ? ($src1_value == $src2_value) :
                     $is_bne ?($src1_value != $src2_value) :
                     $is_bltu ? ($src1_value <  $src2_value) :
                     $is_bgeu ? ($src1_value >= $src2_value) :
                     $is_blt ? (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
                     $is_bgeu ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
                            1'b0;
         
         //BRANCHING PROBLEM SOLUTION FOR READ AFTER WRITE CADENCE 
         // In the case of read after write with a branch condition in next cycle
         // The valid bit here will help increment the PC every cycle instead of every 3 cycles.
         $valid = !(>>1$valid_taken_br || >>2$valid_taken_br || >>1$valid_load || >>2$valid_load); 
         
         //Valid Signal for branching which feeds into PC so that during pipeline unnecesarily PC doesn't
         //Increment for INVALID CYCLES. 
         $valid_taken_br = $valid && $taken_br;
         
         //ALU Implmentation - ADD , ADDI , SUB, OR , AND, XOR PLUS IMMEDIATE
         $result[31:0] = $is_add ?
                         $src1_value[31:0] + $src2_value[31:0] :
                         $is_sub ?
                         $src1_value[31:0] - $src2_value[31:0] :
                         $is_and ?
                         $src1_value[31:0] & $src2_value[31:0] :
                         $is_or ?
                         $src1_value[31:0] | $src2_value[31:0] :
                         $is_xor ?
                         $src1_value[31:0] ^ $src2_value[31:0] :
                         $is_addi ? 
                         $src1_value[31:0] + $imm[31:0] :
                         $is_andi ?
                         $src1_value[31:0] & $imm[31:0] :
                         $is_ori ?
                         $src1_value[31:0] | $imm[31:0] :
                         $is_xori ?
                         $src1_value[31:0] ^ $imm[31:0] :
                         //LOAD AND STORE COMPUTATION
                         $is_load ?
                         $src1_value[31:0] + $imm[31:0] :
                         $is_s_instr ?
                         $src1_value[31:0] + $imm[31:0] :
                         //ALU FOR MISCELLANEOUS OPERATIONS SHIFT OPERATIONS
                         $is_slli ?
                         $src1_value[31:0] << $imm[5:0] :
                         $is_srli ?
                         $src1_value[31:0] >> $imm[5:0] :
                         $is_sll ?
                         $src1_value[31:0] << $src2_value[4:0] :
                         $is_srl ?
                         $src1_value[31:0] >> $src2_value[4:0] :
                         //ALU FOR MISCELLANEOUS OPERATIONS
                         $is_sltu ? $sltu_rslt :
                         $is_sltiu ? $sltiu_rslt :
                         $is_lui ?
                         {$imm[31:12], 12'b0} :
                         $is_auipc ?
                         $pc + $imm :
                         $is_jal ?
                         $pc + 32'd4 :
                         $is_jalr ?
                         $pc + 32'd4 :
                         $is_srai ?
                         { {32{$src1_value[31]}}, $src1_value} >> $imm[4:0] :
                         $is_slt ?
                         ($src1_value[31] == $src2_value[31]) ? $sltu_rslt : {31'b0, $src1_value[31]} :
                         $is_slti ?
                         ($src1_value[31] == $imm[31]) ? $sltu_rslt : {31'b0, $src1_value[31]} :
                         $is_sra ?
                         { {32{$src1_value[31]}}, $src1_value} >> $src2_value[4:0] :
                         32'bx;
         
         $sltu_rslt[31:0]  = $src1_value[31:0] < $src2_value[31:0];
         $sltiu_rslt[31:0] = $src1_value[31:0] < $imm;
         
         //LOAD AND STORE LOGIC 
         $valid_load = $valid && ( $is_load || $is_redge );
         
         //JUMP INSTRUCTIONS LOGIC 
         $is_jump = $is_jal || $is_jalr;
         
         //Validity to ensure only during valid cycles there is jump. 
         $valid_jump = $valid && $is_jump;
         
         //gmem address calculation
         $gmem_wr_add[31:0] = ( $src1_value << SHIFT) + $src2_value;
         
         \SV_plus
               always_ff @(posedge clk) begin
                  \$display(" isedge \%10b or isedgei \%10b is_gr_instr \%10b is_gr_instr \%10b gmem_wr_add \%2d",
                        $is_edge,$is_edgei,$is_gr_instr,$is_gi_instr,$gmem_wr_add);
               end
         
         //$gmem_wr_add = 32'0;
         
         //Register File Write - Considering three cases
         // Will be enabled only when Valid Bit which is helping us construct pipeline is high
         // along with it destination register needs to be valid and destination register cannot
         // be zero as it will be treated as X0 by RISCV ISA standards. 
         \SV_plus
               always_ff @(posedge clk) begin
                  \$display(" >>2$valid_load \%10d >>2$ld_data \%2d",
                        >>2$valid_load, >>2$ld_data);
               end
         
         $rf_wr_en = ($valid && $rd_valid && $rd != 5'b0) || >>2$valid_load;
         $rf_wr_index[4:0] = >>2$valid_load ? >>2$rd : $rd;
         $rf_wr_data[31:0] = >>2$valid_load ? >>2$ld_data : $result;
         
      @4
         //DMEM - Memory Module
         $dmem_wr_en = $is_s_instr && $valid;
         $dmem_rd_en = $is_load;
         $dmem_addr  = $result[5:2];
         $dmem_wr_data[31:0] = $src2_value;
         
         /*
         //sunny adding dummy code
         $gmem_addrx = 32'0;
         $gmem_addry = 32'0;
         $gmem_rd_en = 32'0;
         $gmem_wr_data = 32'0;
         $gmem_wr_en = 32'0;
         */
         
         //$graph_reg_value = 32'5;
         //$gmem_wr_add = 32'0;
         
         //smem sunny
         //$smem_wr_en = $is_s_instr && $valid;
         //$smem_rd_en = $is_load;
         //$smem_addr  = $result[5:2];
         //$smem_wr_data[31:0] = $src2_value;
         $smem_wr_en = ($is_edge || $is_edgei) && $valid;
         $smem_rd_en = $is_redge;
         $smem_addr[31:0]  = $gmem_wr_add;
         //$smem_addr  = 32'0;
         $smem_wr_data[31:0] = $graph_reg_value;
         
         \SV_plus
               always_ff @(posedge clk) begin
                  \$display(" isredge \%10b isedge \%10b or isedgei \%10b is_gr_instr \%10b is_gr_instr \%10b gmem_wr_add \%2d smem_rd_en \%10b smem_addr \%2d",
                        $is_redge, $is_edge,$is_edgei,$is_gr_instr,$is_gi_instr,$gmem_wr_add,$smem_rd_en,$smem_addr);
               end
         
         
         
      @5
         $ld_data[31:0] = $is_redge ? $smem_rd_data : $dmem_rd_data;
         
         \SV_plus
               always_ff @(posedge clk) begin
                  \$display(" $ld_data \%2d $is_redge \%10b $smem_rd_data \%2d  $dmem_rd_data \%2d",
                        $ld_data,$is_redge,$smem_rd_data,$dmem_rd_data);
               end
         
         *passed = |cpu/xreg[17]>>5$value == (1+2+3+4+5+6+7+8+9);
         
         //CLEARING WARNINGS
         `BOGUS_USE($is_addi $is_add $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $imm $imem_rd_en $imem_rd_addr $rd $rs1 $rs2 $is_jalb $start $is_sral $start )
      // Note: Because of the magic we are using for visualisation, if visualisation is enabled below,
      //       be sure to avoid having unassigned signals (which you might be using for random inputs)
      //       other than those specifically expected in the labs. You'll get strange errors for these.
   
   // Assert these to end simulation (before Makerchip cycle limit).
   //*passed = *cyc_cnt > 40;
   *failed = 1'b0;
   
   // Macro instantiations for:
   //  o instruction memory
   //  o register file
   //  o data memory
   //  o CPU visualization
   |cpu
      m4+imem(@1)    // Args: (read stage)
      m4+rf(@2, @3)  // Args: (read stage, write stage) - if equal, no register bypass is required
      m4+dmem(@4)    // Args: (read/write stage)
      //m4+graphMem(@4)
      m4+smem(@4)
   
   m4+cpu_viz(@4)    // For visualisation, argument should be at least equal to the last stage of CPU logic
                       // @4 would work for all labs
\SV
   endmodule

