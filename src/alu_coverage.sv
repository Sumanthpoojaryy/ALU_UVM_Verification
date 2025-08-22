`uvm_analysis_imp_decl(_active_mon)
`uvm_analysis_imp_decl(_passive_mon)

class alu_coverage extends uvm_component;

    `uvm_component_utils(alu_coverage)


    uvm_analysis_imp_active_mon #(alu_sequence_item, alu_coverage) act_mon;
    uvm_analysis_imp_passive_mon #(alu_sequence_item, alu_coverage) pass_mon;


	  alu_sequence_item input_txn, output_txn;
	  real output_coverage,input_coverage;

	  covergroup input_cov;
  
        INPUT_VALID : coverpoint  input_txn.INP_VALID { bins valid_opa = {2'b01};
                                                       bins valid_opb = {2'b10};
                                                       bins valid_both = {2'b11};
                                                       bins invalid = {2'b00};
                                                       }
        COMMAND : coverpoint  input_txn.CMD { bins arithmetic[] = {[0:10]};
                                             bins logical[] = {[0:13]};
                                             bins arithmetic_invalid[] = {[11:15]};
                                             bins logical_invalid[] = {14,15};
                                            }
      	MODE : coverpoint  input_txn.MODE { bins arithmetic = {1};
                                           bins logical = {0};
                                          }
       CLOCK_ENABLE : coverpoint  input_txn.CE { bins clock_enable_valid = {1};
                                                bins clock_enable_invalid = {0};
                                               }
       OPERAND_A : coverpoint  input_txn.OPA { bins opa[]={[0:(2**`WIDTH)-1]};}
       OPERAND_B : coverpoint  input_txn.OPB { bins opb[]={[0:(2**`WIDTH)-1]};}
       CARRY_IN : coverpoint  input_txn.CIN { bins cin_high = {1};
                                             bins cin_low = {0};
                                            }
       MODE_CMD_: cross MODE,COMMAND;

  	endgroup:input_cov

 	  covergroup output_cov;
        RESULT_CHECK:coverpoint output_txn.RES { bins result[]={[0:(2**`WIDTH)-1]};
                                                            option.auto_bin_max = 8;}
        CARR_OUT:coverpoint output_txn.COUT{ bins cout_active = {1};
                                            bins cout_inactive = {0};
                                           }
        OVERFLOW:coverpoint output_txn.OFLOW { bins oflow_active = {1};
                                              bins oflow_inactive = {0};
                                             }
        ERROR:coverpoint output_txn.ERR { bins error_active = {1};
                                        }
        GREATER:coverpoint output_txn.G { bins greater_active = {1};
                                        }
        EQUAL:coverpoint output_txn.E { bins equal_active = {1};
                                      }
        LESSER:coverpoint output_txn.L { bins lesser_active = {1};
                                       }
    
  	endgroup:output_cov

	  function new(string name = "", uvm_component parent);
  	  	super.new(name, parent);
  		  input_cov = new;
        output_cov = new;
        act_mon = new("act_mon", this);
        pass_mon = new("pass_mon", this);
	  endfunction:new
  

  	function void write_active_mon(alu_sequence_item t);

      	input_txn = t;
        input_cov.sample();
	  endfunction:write_active_mon
  
	  function void write_passive_mon(alu_sequence_item t);
        output_txn = t;
        output_cov.sample();
	  endfunction:write_passive_mon
  
  
	  function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        input_coverage = input_cov.get_coverage();
        output_coverage = output_cov.get_coverage();
  	endfunction:extract_phase

	  function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info(get_type_name, $sformatf("[INPUT] Coverage ------> %0.2f%%,", input_coverage), UVM_MEDIUM);
      `uvm_info(get_type_name, $sformatf("[OUTPUT] Coverage ------> %0.2f%%", output_coverage), UVM_MEDIUM);
  	endfunction:report_phase

endclass:alu_coverage
