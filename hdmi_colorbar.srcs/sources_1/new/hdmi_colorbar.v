`timescale  1ns/1ns

module  hdmi_colorbar
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效

    output  wire            ddc_scl     ,
    inout   wire            ddc_sda     ,
    output  wire            hdmi_out_clk,
    output  wire            hdmi_out_rst_n      ,
    output  wire            hdmi_out_hsync      ,   //输出行同步信号
    output  wire            hdmi_out_vsync      ,   //输出场同步信号
    output  wire    [23:0]  hdmi_out_rgb        ,   //输出像素信息
    output  wire            hdmi_out_de
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire            locked  ;   //PLL locked信号
wire            rst_n   ;   //VGA模块复位信号
wire    [11:0]  pix_x   ;   //VGA有效显示区域X轴坐标
wire    [11:0]  pix_y   ;   //VGA有效显示区域Y轴坐标
wire    [15:0]  pix_data;   //VGA像素点色彩信息
wire    [15:0]  rgb     ;   //输出像素信息

//rst_n:VGA模块复位信号
assign  rst_n   = (sys_rst_n & locked);
assign  hdmi_out_rst_n=rst_n;
//assign  rst_n   = sys_rst_n;
assign  hdmi_out_rgb   ={{rgb[15:11],3'b0},{rgb[10:5],2'b0},{rgb[4:0],3'b0}};

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

clk_wiz_0 clk_gen_inst
(
    .reset      (~sys_rst_n     ),  //输入复位信号,高电平有效,1bit
    .clk_in1    (sys_clk        ),  //输入50MHz晶振时钟,1bit

    .clk_out1   (hdmi_out_clk   ),  //输出VGA工作时钟,频率25Mhz,1bit
    .locked     (locked         )   //输出pll locked信号,1bit
);


hdmi_i2c hdmi_i2c_inst(
 .sys_clk   (sys_clk    )  ,   //系统时钟
 .sys_rst_n (sys_rst_n  ),   //复位信号
 .cfg_done  (           )         ,   //寄存器配置完成
 .sccb_scl  (ddc_scl    )  ,   //SCL
 .sccb_sda  (ddc_sda    )         //SDA

    );
//------------- vga_ctrl_inst -------------
vga_ctrl  vga_ctrl_inst
(
    .vga_clk    (hdmi_out_clk   ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n          ),  //输入复位信号,低电平有效,1bit
    .pix_data   (pix_data       ),  //输入像素点色彩信息,16bit

    .pix_x      (pix_x          ),  //输出VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y          ),  //输出VGA有效显示区域像素点Y轴坐标,10bit
    .hsync      (hdmi_out_hsync ),  //输出行同步信号,1bit
    .vsync      (hdmi_out_vsync ),  //输出场同步信号,1bit
    .rgb_valid  (hdmi_out_de    ),
    .rgb        (rgb            )   //输出像素点色彩信息,16bit
);

//------------- vga_pic_inst -------------
vga_pic vga_pic_inst
(
    .vga_clk    (hdmi_out_clk   ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n          ),  //输入复位信号,低电平有效,1bit
    .pix_x      (pix_x          ),  //输入VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y          ),  //输入VGA有效显示区域像素点Y轴坐标,10bit

    .pix_data   (pix_data       )   //输出像素点色彩信息,16bit

);


endmodule
