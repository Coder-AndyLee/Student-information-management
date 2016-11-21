data segment
    stunum db 0H 
    temp db 0H
    avescore db 0H
    info db 63h dup(1ch dup(0h))
    enter db 0Dh,0AH,'$'
    section db 05h dup(0h) 
    pkey db "press any key...$"
    menu1 db 0Dh,0AH,'------------------------------------------------',0Dh,0AH,'| Welcome to the performance management system |',0Dh,0AH,'| 1---Rank                                     |',0Dh,0AH,'| 2---Calculate the average score              |',0Dh,0AH,'| 3---Get the score section                    |',0Dh,0AH,'| 4---Exit                                     |',0Dh,0AH,'| Please input your choice:                    |',0Dh,0AH,'------------------------------------------------',0Dh,0AH,'$' 
    num_input db 'Please input the students number:',0Dh,0AH,'$'
    name_input db 'Please input the student��s name',0Dh,0AH,'$'
    class_input db 'Please input the class number',0Dh,0AH,'$'
    id_input db 'Please input the student ID',0Dh,0AH,'$'
    score_input db 'Please input the score',0Dh,0AH,'$'
    wrong_input db 'Input error,please input the right order:$'
    
    name_output db 0dh,0ah,'Name:$'
    class_output db 0dh,0ah,'Class:$'
    id_output db 0dh,0ah,'ID:$'
    score_output db 0dh,0ah,'Score:$'
    ave_output db 0dh,0ah,'The average score is :$'
    score_section db 0dh,0ah,'The score section is showed below:$'
    score1 db 0ah,0dh,'0-59:$'
    score2 db 0ah,0dh,'60-69:$'
    score3 db 0ah,0dh,'70-79:$'
    score4 db 0ah,0dh,'80-89:$'
    score5 db 0ah,0dh,'90-100:$'  
data ends

stack segment
    dw   128  dup(0)
ends

16_10_print macro a          ;��ʮ������ת����ʮ���Ʋ����
    local one,two,two1,three
    push ax
    push bx
    push cx
    push dx
one:
    xor dx,dx           ;��ʼ���Ĵ���dx
    mov al,a
    mov bl,100
    and ax,00ffh  
    div bl
    mov bh,ah
    mov dl,al
    add dl,30h
    mov dh,dl
    cmp dl,30h
    jz two    
    mov ah,02h
    int 21h
two:
    mov bl,10
    mov ax,0
    mov al,bh
    div bl
    mov bh,ah
    mov dl,al
    add dl,30h    
    cmp dl,30h          ;�ж�ʮλ�Ƿ�Ϊ0
    jnz two1            ;ʮλ������0�����
    cmp dh,30h          ;ʮλ����0�򿴰�λ
    jz three            ;��λҲ��������ֱ�������λ   
two1:          
    mov ah,02h
    int 21h
three:
    mov dl,bh
    add dl,30h
    mov ah,02h
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
endm

printf macro str        ;���str����
    push AX
    push DX
    lea DX,str          ;����˵���ʾָ��
    mov AH,09H
    int 21H
    pop DX
    pop AX
endm 

scanf_AL macro          ;����һ���ַ�
    mov AH,01h
    int 21H
endm
 
input_number macro      ;����ѧ���������Իس���β
    local input_num,end_num
    printf num_input
    lea si,stunum
    mov DL,0H
    input_num:          ;����ѧ���������Իس���β
        scanf_AL
        cmp AL,0DH
        je end_num
        sub AL,30H      ;��asc��ת����ʮ���ƴ洢
        mov DH,AL
        mov AL,DL
        mov DL,0AH
        mul DL          ;����һλ����10��������һλ������ɴ洢
        add AL,DH
        mov DL,AL
        jmp input_num
    end_num:
        mov [si],DL     ;��ʱ�ڲ�������Ϊ16���Ƶ�
        add si,1
        printf enter 
endm

input_info macro        ;����ÿ��ѧ���ĸ�����Ϣ
    local info_,name_,next,class,id,score,next1
    lea si,info
info_:
    printf enter    
    printf name_input
    mov cx,13h
name_:
    scanf_AL
    cmp al,0dh
    jz next
    mov [si],al
    add si,1        ;si����ƫ��һλ
    loop name_
next:
    mov [si],24h    ;24h��$�ı���
    add cx,1        ;��������������ϳ�20λ��������siƫ�Ƶ�ַ��������ƶ�20λ��������������֣�
    add si,cx

    printf enter
    printf class_input
    mov cx,02h
class:
    scanf_AL
    mov [si],al     ;��ͬ���ķ�ʽ����class
    add si,1
    loop class
    mov [si],24h
    add si,1
    
    printf enter
    printf id_input
    mov cx,02h
id:
    scanf_AL        ;��ͬ���ķ�ʽ����id
    mov [si],al
    add si,1
    loop id
    mov [si],24h
    add si,1
    
    printf enter
    printf score_input
    mov cx,03h
    
    xor bx,bx
    xor ax,ax
    mov dl,0H
score:
    scanf_AL        ;��ͬ���ķ�ʽ����score
    cmp al,0dh
    jz next1
    sub al,30h
    mov bl,al
    mov al,dl
    mov bh,0ah
    mul bh
    add al,bl
    mov dl,al 
    loop score
    
next1:
    mov [si],dl
    add si,1
    mov [si],24h
    add si,1
    dec dh
    jnz info_ 
endm

menu macro             ;��ɲ˵����ܲ����ĺ�
    menu:
    printf menu1
    scanf_AL
    cmp al,31h          ;������������֣���ɹ�����ת
    jz paixu
    cmp al,32h
    jz cal
    cmp al,33h
    jz score_section_
    cmp al,34h
    jz endr 

paixu:
    local score_find,stu_find,cal,sum,divide,score_section_,select,section0_59,section60_69,section70_79,section80_89,section90_100,print_select                                                               
    lea di,stunum
    xor ax,ax
    xor cx,cx
    mov ch,65h   ;65h=101
score_find:      ;��100-0��ʼ��ÿ������Ѱ���Ƿ��ж�Ӧ��ѧ��
    sub ch,1
    js menu
    lea si,info
    sub si,1ch   ;1ch=28
    mov cl,[di]
    add cl,1
stu_find:           ;Ѱ�Ҷ�Ӧ�ķ���
    dec cl
    jz score_find
    add si,1ch
    cmp [si+26],ch ;ch��ʱ��ֵΪ64h (100)
    jnz stu_find
    mov dx,si
    printf name_output
    mov ah,09h
    int 21h     
    add dx,14h      ;ƫ��20λ���ҵ�classλ��
    printf class_output
    int 21h
    add dx,03h      ;ƫ��3λ���ҵ�idλ��
    printf id_output
    int 21h
    printf score_output  
    16_10_print [si+26]
    printf enter
    jmp stu_find
cal:
    xor cx,cx
    xor ax,ax     
    xor dx,dx
    lea di,stunum   ;����ѧ��������ѩ��ѭ������
    mov cl,[di]
    add cl,1
    lea si,info
    sub si,1ch   
sum:
    add si,1ch      ;��������ͬѧ�ܷ���
    dec cl
    jz divide
    add al,[si+26]
    jmp sum
divide:             ;��ɳ���������ƽ��ֵ
    div [di]
    printf ave_output
    16_10_print al
    printf enter
    printf enter
    jmp menu
score_section_:     ;���������������
    printf score_section
    xor cx,cx
    xor ax,ax
    xor dx,dx
    lea si,info
    sub si,1ch
    lea di,stunum
    mov cl,[di]
    add cl,1
    lea di,section
select:
    dec cl
    jz print_select
    add si,1ch      
    cmp [si+26],3ch ;�Ƿ�С��60
    js section0_59
    cmp [si+26],46h ;�Ƿ�С��70
    js section60_69         
    cmp [si+26],50h ;�Ƿ�С��80
    js section70_79
    cmp [si+26],5ah ;�Ƿ�С��90
    js section80_89
    cmp [si+26],65h ;�Ƿ�С��101
    js section90_100    
section0_59:
    add [di],1      ;��0-59����������+1
    jmp select
section60_69:
    add [di+1],1    ;��60-69����������+1
    jmp select
section70_79:
    add [di+2],1    ;��70-79����������+1 
    jmp select
section80_89:
    add [di+3],1    ;��80-89����������+1
    jmp select
section90_100:
    add [di+4],1    ;��90-100����������+1
    jmp select 
print_select:
    printf score1
    16_10_print [di]     ;�����֮�󣬽��Ĵ�������
    mov [di],0
    printf enter
    
    printf score2
    16_10_print [di+1]   ;�����֮�󣬽��Ĵ�������
    mov [di+1],0
    printf enter
     
    printf score3
    16_10_print [di+2]   ;�����֮�󣬽��Ĵ�������
    mov [di+2],0
    printf enter
    
    printf score4
    16_10_print [di+3]   ;�����֮�󣬽��Ĵ�������
    mov [di+3],0
    printf enter
    
    printf score5
    16_10_print [di+4]   ;�����֮�󣬽��Ĵ�������
    mov [di+4],0
    printf enter
    jmp menu    
endm
    
 
;�����
code segment
    assume cs:code,DS:data,SS:stack
start:
    mov AX, data
    mov DS, AX
     
    input_number        ;����ѧ�������ĺ�
    input_info          ;����ÿ��ѧ���ĸ�����Ϣ
    menu                ;��ɲ˵����ܵĺ�      
    
endr:
    printf enter        
    lea DX, pkey
    mov AH, 09H
    int 21H         ; output string at DS:DX    
                    ; wait for any key....    
    mov AH, 01H
    int 21H
        
    printf enter
    mov AX, 4c00H ; exit to operating system.
    int 21H
            
ends
end start ; set entry point and stop the assembler.