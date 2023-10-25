`ifndef FPU_32_V
`define FPU_32_V

// Description: 32-bit floating point unit.
// operands: a, b
// operations: add, sub, cmp
module fpu_32 (
    input wire clk,
    input wire rstn,

    input wire valid,
    output wire ready,
    output wire idle,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] op,
    output reg [31:0] out
);

reg [1:0] state;
reg [31:0] a_reg;
reg [31:0] b_reg;

assign ready = (state == 2'b11) & valid;
assign idle = (state == 2'b00) & !valid;

wire done;

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        state <= 2'b00;
        a_reg <= 32'h00000000;
        b_reg <= 32'h00000000;
    end else begin
        case (state)
            2'b00: begin
                if (valid) begin
                    a_reg <= (a[30:23] > b[30:23]) ? a : b;
                    b_reg <= (a[30:23] > b[30:23]) ? b : a;
                    state <= 2'b01;
                end
            end
            2'b01: begin
                if (done) state <= 2'b11;
            end
            2'b11: begin
                if (!valid) state <= 2'b00;
            end
        endcase
    end
end

wire a_sign, b_sign;
wire [7:0] a_exp, b_exp;
wire [22:0] a_frac, b_frac;

assign {a_sign, a_exp, a_frac} = a_reg;
assign {b_sign, b_exp, b_frac} = b_reg;

reg done_reg;
reg [1:0] add_sub_state;
wire [8:0] exp_diff;
reg [24:0] t1, t2;

assign exp_diff = a_exp - b_exp;

always @ (posedge clk) begin
    if (~rstn) begin
        done_reg <= 1'b0;
        add_sub_state <= 0;
    end
    if (state == 2'b11) begin
        done_reg <= 1'b0;
        add_sub_state <= 0;
    end else if (state == 2'b10) begin
        if (op == 3'b00x) begin
            if (exp_diff > 8'd23) begin 
                out <= a_reg;
                done_reg <= 1'b1;
            end
            else if (add_sub_state == 2'b00) begin
            end

        end
    end
end
    
endmodule

`endif // FPU_32_V