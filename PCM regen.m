close all;
clc;
clear all;
%{
function regenerator take the distorted signal and clock signal as
and threshold arguments and if the distorted signal value is above
the threshold value ,it make the out bit as 1 else 0;
A buffer holds the value until next clock signal


%}
function out_sig = regenerator(sig,clk,thr_hld)
 out_sig = zeros(size(sig))
 buffer = 0;
 for i = 1:size(sig)(2)
 if(clk(i)==1)
 if(sig(i)>=thr_hld)
 out_sig(i) = 1 ;
 buffer = 1;
 else
 buffer = 0;
 endif
 else
 out_sig(i) = buffer;
 endif
 endfor;
endfunction;
%{
 CLK_SIG function generate clock signal
%}
function clk = CLK_SIG(sig,freq)
 clk = zeros(1,size(sig)(2));
 for i = 1:size(sig)(2)
 if(rem(i,freq)==0)
 clk(1,i) = 1;
 endif
 endfor
endfunction;
%{
in_sig_gen function generate a random NZR coded signal
the number of bits is n*100 bits
%}
function[t_sig,in_signal] = in_sig_gen(n)
 sig = rand(1,n)>0.5;
 sig = repmat(sig',1,50)';
in_signal = sig(:)';
 t_sig = linspace(0,n,numel(in_signal));
 endfunction;
 %{
dist_sig_gen function create a random distortion signal with
max amplitude = dist_fact and add it to the signal
%}
function out_dist_sig = dist_sig_gen(sig,dist_fact)
 dist_sig = dist_fact*rand(size(sig));
 %figure(2);
 %plot(dist_sig)
 out_dist_sig = dist_sig.+sig;
 endfunction;
%{
equalize function normalizes the distorted signal
%}
function equal_out = equalize(sig)
 equal_out = ((sig-min(sig))/(max(sig)-min(sig)));
% equal_out = ((sig)/(max(sig)-min(sig)));
endfunction;
%{
biterror function finds the total number of bits , number of error
bits and bit_er(bit error ratio)
%}
function [no_bit,no_error_bit,bit_er] = biterror(in_sig,out_sig)
 no_bit = size(in_sig)(2);
 no_error_bit = 0;
 for i = 1:no_bit
 if(in_sig(i)!=out_sig(i))
 no_error_bit +=1;
 endif;
 endfor;
 bit_er = no_error_bit/no_bit;
 endfunction;

dist_amp = 0.70 % distortion amplitude multiplication factor
threshold = 0.45 % value range from 0 to 1 to set the threshold for regenerator
n_val = 10; % no of bits = n_val*100
clk_timeper = 4; % clock time period clcok of every multiple of clk_timeper
%inputsignal generation
[t_sig,in_sig]=in_sig_gen(n_val);
%distoring the input signal
dist_sig = dist_sig_gen(in_sig,dist_amp);
%equalizing the distorted signal
eq_sig = equalize(dist_sig);
%genetate clock signal
clk_out = CLK_SIG(eq_sig,clk_timeper);
%regenerate the distorted signal
end_sig = regenerator(eq_sig,clk_out,threshold);
figure(3);
subplot(5,1,1)
plot(t_sig,in_sig);
title("input signal");
axis([0,n_val,0,1.5]);
subplot(5,1,2)
plot(t_sig,dist_sig);
title("distorted signal");
subplot(5,1,3)
plot(t_sig,eq_sig); hold on;
line([0 n_val],[threshold threshold],"color","b"); hold off;
title("normalized signal")
subplot(5,1,4);
stem(t_sig,clk_out);
title("clock signal");
subplot(5,1,5)
stairs(t_sig,end_sig)
title("regenerated signal");
axis([0,n_val,0,1.5]);
[t_bit,t_error,ber] = biterror(in_sig,end_sig);
printf("total no of bits transmitted : %d\n",t_bit);
printf("no of error bits : %d\n",t_error);
printf("bit error ratio : %d\n",ber);
