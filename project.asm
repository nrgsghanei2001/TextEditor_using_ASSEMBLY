sys_read     equ     0
sys_write    equ     1
sys_open     equ     2
sys_close    equ     3
sys_lseek    equ     8
sys_create   equ     85
sys_unlink   equ     87
sys_mkdir       equ 83
sys_makenewdir  equ 0q777
sys_mmap     equ     9
sys_mumap    equ     11
sys_brk      equ     12  
sys_exit     equ     60
stdin        equ     0
stdout       equ     1
stderr       equ     3
PROT_NONE	  equ   0x0
PROT_READ     equ   0x1
PROT_WRITE    equ   0x2
MAP_PRIVATE   equ   0x2
MAP_ANONYMOUS equ   0x20
;access mode
O_DIRECTORY equ     0q0200000
O_RDONLY    equ     0q000000
O_WRONLY    equ     0q000001
O_RDWR      equ     0q000002
O_CREAT     equ     0q000100
O_APPEND    equ     0q002000
BEG_FILE_POS    equ     0
CURR_POS        equ     1
END_FILE_POS    equ     2
;sys codes end
; create permission mode
sys_IRUSR     equ     0q400      ; user read permission
sys_IWUSR     equ     0q200      ; user write permission
NL            equ   0xA
Space         equ   0x20
;----------------------------------------------------
section  .fileIO
    error_create        db      "error in creating file             ", NL, 0
    error_close         db      "error in closing file              ", NL, 0
    error_write         db      "error in writing file              ", NL, 0
    error_open          db      "error in opening file              ", NL, 0
    error_open_dir      db      "error in opening dir               ", NL, 0
    error_append        db      "error in appending file            ", NL, 0
    error_delete        db      "error in deleting file             ", NL, 0
    error_read          db      "error in reading file              ", NL, 0
    error_print         db      "error in printing file             ", NL, 0
    error_seek          db      "error in seeking file              ", NL, 0
    error_create_dir    db      "error in creating directory        ", NL, 0
    suces_create        db      "file created and opened for R/W    ", NL, 0
    suces_create_dir    db      "dir created and opened for R/W     ", NL, 0
    suces_close         db      "file closed                        ", NL, 0
    suces_write         db      "written to file                    ", NL, 0
    suces_open          db      "file opend for R/W                 ", NL, 0
    suces_open_dir      db      "dir opened for R/W                 ", NL, 0
    suces_append        db      "file opened for appending          ", NL, 0
    suces_delete        db      "file deleted                       ", NL, 0
    suces_read          db      "reading file                       ", NL, 0
    suces_seek          db      "seeking file                       ", NL, 0
;-------------------------------------------------------
section .data
    menu_option_messages              db     "Please choose one option.", 0                  
    menu_option_show                  db     "1-Show files context.", 0                  
    menu_option_report                db     "2-Report file context's data.", 0                  
    menu_option_search                db     "3-Search in file.", 0                  
    menu_option_replace               db     "4-Search and replace.", 0                  
    menu_option_append                db     "5-Append to file.", 0                  
    menu_option_delete                db     "6-Delete from file.", 0                  
    menu_option_save                  db     "7-Save changes.", 0                  
    menu_option_saveas                db     "8-Save and create new file.", 0                  
    menu_option_exit                  db     "0-Exit the program.", 0  
    menu_option_choose                db     "Enter a number:", 0                
    invalid_option                    db     "This is not a valid option code. Please try again.:", 0  
    get_file_address_message          db     "Enter file address:", 0     
    show_context_message              db     "Context of this file:", 0
    old_file_message                  db     "There is already an open file. Do you want to continue with old file?(y/n)", 0
    old_file_error                    db     "This is not a valid input.", 0
    line                              db     "################################################", 0
    num_of_char_message               db     "Number of characters is: ", 0
    num_of_word_message               db     "Number of words is: ", 0
    num_of_line_message               db     "Number of lines is: ", 0
    line_message                      db     " and line ", 0
    index_message                     db     "The word is appeared in index ", 0
    total_word_message                db     "Total number of founded words is ", 0
    enter_word_message                db     "Enter the word: ", 0
    replace_search_word_message       db     "The word is found in: ", 0
    append_message                    db     "Please enter the text you want to append this file and put $ then enter at the end: ", 0
    replace_search_newWord_message    db     "Please enter new word: ", 0
    replace_search_index_message      db     " Please enter 1 if you want to replace this and anything to continue: ", 0
    delete_message                    db     "Enter number of characters you want to delete from end of the file:  ", 0
    temp_file                         db     "./temp.txt", 0
    filehandle                        dq     0
    FD_txt:                           dq     0               ; file description of text files         
;--------------------------------------------------------
section .bss 
    file_dir             resb   1000       ; address of file
    buffer_of_text       resb    1000000   ; context of file
    searched_word        resb    1000      ; word give to search
    result_of_search     resq   1000      ; saves indexes that the searched word founded in
    new_replace_word     resb   1000      ; the word that is replaced by searched word
    temp_buffer          resb  1000000    ; buffer to write in temp file
    append_buffer        resb  1000000    ; buffer to save context to append
    replace_indexes      resq  1000    ; buffer of saving indexes which should be replaced with new word

;---------------------------------------------------------
section .text
;----------------------------------------------------
createFile:
    push rsi
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rsi, suces_create           
    call    printString
    pop rsi
    ret
    createerror:
        mov     rsi, error_create
        call    printString
        pop rsi
        ret
;----------------------------------------------------
openFile:
    push rsi
    mov     rax, sys_open
    mov     rsi, O_RDWR     
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov rsi, suces_open
    call printString
    call newLine
    jmp     ExitOpenFile
    openerror:
        mov     rsi, error_open
        call    printString
        call    newLine
        pop rsi
        jmp     Exit

    ExitOpenFile:
        pop rsi
        ret 
;----------------------------------------------------
Open_Dir:
    enter 0, 0
    %define folder_name qword[rbp+16]
    push rsi
    push rdi

    mov     rax, sys_open
    mov     rdi, folder_name
    mov     rsi, O_DIRECTORY
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     open_dir_error
    mov     rsi, suces_open
    call    printString
    jmp     Exit_open_dir

    open_dir_error:
        mov     rsi, error_open
        call    printString
        jmp     Exit
    
    Exit_open_dir:
        pop rdi
        pop rsi
        %undef folder_name
        leave
        ret 8
;----------------------------------------------------
appendFile:

    mov     rax, sys_write
    mov     rsi, O_RDWR | O_APPEND
    syscall
    cmp     rax, -1     ; file descriptor in rax
    jle     appenderror
    mov     rsi, suces_append
    call    printString
    ret
    appenderror:
        mov     rsi, error_append
        call    printString
        ret
;----------------------------------------------------
writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         ; number of written byte
    jle     writeerror
    mov     rsi, suces_write
    call    printString
    ret
    writeerror:
        mov     rsi, error_write
        call    printString
        ret
;----------------------------------------------------
readFile:
    push rsi
    mov     rax, sys_read
    syscall
    cmp     rax, -1           ; number of read byte
    jle     readerror
    mov     byte [rsi+rax], 0 ; add a  zero
    mov rsi, suces_read
    call  printString
    call newLine
    jmp     ExitRead

    readerror:
        mov rsi, error_read
        call printString
        call newLine
        pop rsi
        jmp Exit

    ExitRead:
        pop rsi
        ret
;----------------------------------------------------
closeFile:
    mov     rax, sys_close
    syscall
    cmp     rax, -1      ; 0 successful
    jle     closeerror
    mov     rsi, suces_close
    call    printString
    ret
    closeerror:
        mov     rsi, error_close
        call    printString
        ret

;----------------------------------------------------
deleteFile:
    mov     rax, sys_unlink
    syscall
    cmp     rax, -1      ; 0 successful
    jle     deleterror
    ret
    deleterror:
        ret
;----------------------------------------------------
seekFile:
    mov     rax, sys_lseek
    syscall
    cmp     rax, -1
    jle     seekerror
    mov     rsi, suces_seek
    call    printString
    ret
    seekerror:
        mov     rsi, error_seek
        call    printString
        ret

;--------------------------------------------------- 
newLine:
    push   rax
    mov    rax, NL
    call   putc
    pop    rax
    ret
;---------------------------------------------------------
OneSpace:
    push   rax
    mov    rax, Space
    call   putc
    pop    rax
    ret
;---------------------------------------------------------
OneLine:
    push   rsi
    mov    rsi, line
    call   printString
    call newLine
    pop    rsi
    ret
;---------------------------------------------------------
putc:	

    push   rcx
    push   rdx
    push   rsi
    push   rdi 
    push   r11 

    push   ax
    mov    rsi, rsp    ; points to our char
    mov    rdx, 1      ; how many characters to print
    mov    rax, sys_write
    mov    rdi, stdout 
    syscall
    pop    ax

    pop    r11
    pop    rdi
    pop    rsi
    pop    rdx
    pop    rcx
    ret
;---------------------------------------------------------
writeNum:
    push   rax
    push   rbx
    push   rcx
    push   rdx

    sub    rdx, rdx
    mov    rbx, 10 
    sub    rcx, rcx
    cmp    rax, 0
    jge    wAgain
    push   rax 
    mov    al, '-'
    call   putc
    pop    rax
    neg    rax  

    wAgain:
        cmp    rax, 9	
        jle    cEnd
        div    rbx
        push   rdx
        inc    rcx
        sub    rdx, rdx
        jmp    wAgain

    cEnd:
        add    al, 0x30
        call   putc
        dec    rcx
        jl     wEnd
        pop    rax
        jmp    cEnd
    wEnd:
        pop    rdx
        pop    rcx
        pop    rbx
        pop    rax
        ret

;---------------------------------------------------------
getc:
    push   rcx
    push   rdx
    push   rsi
    push   rdi 
    push   r11 


    sub    rsp, 1
    mov    rsi, rsp
    mov    rdx, 1
    mov    rax, sys_read
    mov    rdi, stdin
    syscall
    mov    al, [rsi]
    add    rsp, 1

    pop    r11
    pop    rdi
    pop    rsi
    pop    rdx
    pop    rcx

    ret
;---------------------------------------------------------
readNum:
    push   rcx
    push   rbx
    push   rdx

    mov    bl,0
    mov    rdx, 0
    rAgain:
        xor    rax, rax
        call   getc
        cmp    al, '-'
        jne    sAgain
        mov    bl,1  
        jmp    rAgain
    sAgain:
        cmp    al, NL
        je     rEnd
        cmp    al, ' ' ;Space
        je     rEnd
        sub    rax, 0x30
        imul   rdx, 10
        add    rdx,  rax
        xor    rax, rax
        call   getc
        jmp    sAgain
    rEnd:
        mov    rax, rdx 
        cmp    bl, 0
        je     sEnd
        neg    rax 
    sEnd:  
        pop    rdx
        pop    rbx
        pop    rcx
        ret
;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall 

    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx
    pop     rax
    pop     rcx
    pop     rbx
    ret
;-------------------------------------------
f_get_file_address:
    push rsi
    push rax

    mov rsi, get_file_address_message
    call printString
    call OneSpace

    mov rsi, file_dir
    get_file_address:                ; get file address                     
        mov  rax, 0
        call getc                    ; get one char
        cmp  al, NL                  ; check if enter entered and string is finished
        je   end_get_file_address
        mov  [rsi], al               ; else: put input char in file address
        inc  rsi                     ; point to next free place
        jmp  get_file_address        ; get next char

    end_get_file_address:
        mov byte[rsi], 0             ; put a 0 at the end of address

        pop rax
        pop rsi
        ret
;-------------------------------------------
f_free:
    enter 0, 0
    %define address qword[rbp+16]
    %define size    qword[rbp+24]
    push rsi
    push rcx

    mov rsi, address
    mov rcx, size

    loop_free:
        mov byte[rsi], 0        ; put 0 in all places in pointed array
        inc rsi
        loop loop_free
    
    end_free_address:
        pop rcx
        pop rsi
        %undef address
        %undef  size
        leave
        ret 16
;-------------------------------------------
f_free_8byte:
    enter 0, 0
    %define address qword[rbp+16]
    %define size    qword[rbp+24]
    push rsi
    push rcx

    mov rsi, address
    mov rcx, size

    loop_free1:
        mov qword[rsi], 0        ; put 0 in all places in pointed array
        add rsi, 8
        loop loop_free1
    
    end_free_address1:
        pop rcx
        pop rsi
        %undef address
        %undef  size
        leave
        ret 16
;-------------------------------------------
check_for_old_file:
    push rdi
    push rdx
    push rsi
    push rax
    mov rax, 0

    mov rdi, file_dir
    call GetStrlen
    cmp rdx, 0                    ; if file_dir is empty
    je  end_check_for_old_file
    mov rsi, old_file_message     ; else: check if user wants to continue
    call printString
    call OneSpace
    call getc                     ; get n or y
    mov r8, rax                   ; save input in r8 to return it
    call getc                     ; get any char to end this part

    end_check_for_old_file:
        pop rax
        pop rsi
        pop rdx
        pop rdi
        ret
;-------------------------------------------
f_open_and_read_file:
    push r8
    push rsi
    push rdi
    push rdx
    mov rax, -1                                 

    mov r8, 110                      ; new file by default
    call check_for_old_file          ; check if any file address previously entered
    cmp  r8, 110                     ; user does not want to continue with old file
    je   get_new_file
    cmp  r8, 121
    je   open_file              ; user wants to continue with old file
    mov rsi, old_file_error     ; input char is neither n nor y
    call printString
    jmp exit_f_open_and_read_file

    get_new_file:
        push 1000
        push file_dir
        call f_free        ; free previous address
        push 1000000
        push buffer_of_text
        call f_free        ; free previous text buffer
        call f_get_file_address    ; get new address

    open_file:                       ; open text file
        mov rdi, file_dir
        call openFile
        mov [FD_txt], rax

    readTextFile:                    ; read context of text file
        mov  rdi, [FD_txt]
        mov  rsi, buffer_of_text
        mov  rdx, 1000000
        call readFile

    exit_f_open_and_read_file:
        pop rdx
        pop rdi
        pop rsi
        pop r8
        ret
;-------------------------------------------
f_find_line:
    enter 0, 0
    push rax
    push rbx
    push rcx
    push rsi

    mov rax, qword[rbp+16]        ; index of found word
    mov rsi, buffer_of_text
    mov rcx, 0
    mov rdx, 0             ; number of lines seen
    loop_find_line:
        cmp rcx, rax
        je  exit_f_find_line
        mov bl, [rsi+rcx]
        cmp bl, NL           ; count number of enters before given index
        je  incOneLine
        inc rcx
        jmp loop_find_line

    incOneLine:
        inc rdx
        inc rcx
        jmp loop_find_line

    exit_f_find_line:
        pop rsi
        pop rcx
        pop rbx
        pop rax
        leave
        ret 8
;-------------------------------------------
show_search_result:

    push rax
    push rbx
    push rcx
    push rdx
    push rsi

    mov rbx, result_of_search
    mov rcx, 0

    loop_show_result:
        cmp rcx, r15
        je  exit_show_search_result
        mov rax, [rbx]
        add rbx, 8
        mov rsi, index_message
        call printString
        call writeNum
        push rax
        call f_find_line              ; return the line that this words appears in rdx
        mov rax, rdx
        inc rax
        mov rsi, line_message
        call printString
        call writeNum
        call newLine
        inc rcx
        jmp loop_show_result

    exit_show_search_result:
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
;-------------------------------------------
f_sub_search:
    push rax
    push rsi
    push r8
    push rdi
    push r10
    push r9
    push rcx
    push rdx
    push r14

    call f_open_and_read_file   ; check for old open files and open and read the file
    cmp rax, -1
    je exit_f_sub_search
    mov r15, 0                   ; total number of founded words
    mov r14, result_of_search

    get_searched_word:                    ; get word   
        mov rsi, enter_word_message
        call printString
        mov rsi, searched_word
        loop_get_searched_word:               
            mov  rax, 0
            call getc                     ; get one char
            cmp  al, NL                   ; check if enter entered and string is finished
            je   search                   ; go to search word
            mov  [rsi], al                ; else: put input char in word
            inc  rsi                      ; point to next free place
            jmp  loop_get_searched_word   ; get next char
    

    search:          ; search word in context
        mov rsi, buffer_of_text
        mov r8, rsi
        mov rdi, rsi
        call GetStrlen      ; len of text
        add rdi, rdx
        mov r10, rdi        ; r11 = end of file
        mov r9, searched_word
        mov rax, 0

        again:
            mov rdi, searched_word
            call GetStrlen
            mov rcx, rdx
            mov rsi, r8
            mov rdi, r9
            repe cmpsb
            je foundOne    ; one occurrence found
            inc r8         ; check for others
            cmp r8, r10
            jne again
            jmp exit_f_sub_search

        foundOne:
            inc r15
            mov rax, r8
            sub rax, buffer_of_text       ; find the index of appearance
            mov [r14], rax                ; put the result in result array
            add r14, 8
            mov rdi, searched_word
            call GetStrlen                  ; go search for next index after current word
            add r8, rdx
            cmp r8, r10
            jnge again

    exit_f_sub_search:
        pop r14
        pop rdx
        pop rcx
        pop r9
        pop r10
        pop rdi
        pop r8
        pop rsi
        pop rax
        ret
;-------------------------------------------
input_string:
    push rax
    push rsi

    mov rsi, new_replace_word
    loop_get_string:
        xor rax, rax
        call getc
        cmp al, NL
        je  exit_input_string
        mov [rsi], al
        inc rsi
        jmp loop_get_string

    exit_input_string:
        mov byte[rsi], 0
        pop rsi
        pop rax
        ret
;-------------------------------------------
input_text:
    push rax
    push rsi
    push rdi
    push rdx

    mov rdi, buffer_of_text
    call GetStrlen
    mov rsi, temp_buffer
    add rsi, rdx          ; scape for text file itself
    loop_get_text:
        xor rax, rax
        call getc
        cmp al, 36
        je  exit_input_text
        mov [rsi], al
        inc rsi
        jmp loop_get_text

    exit_input_text:
        call getc
        mov byte[rsi], 0
        pop rdx
        pop rdi
        pop rsi
        pop rax
        ret
;-------------------------------------------
copy_buffer:
    enter 0, 0
    %define source qword[rbp+16]
    %define destination qword[rbp+24]
    %define size qword[rbp+32]
    push rdi
    push rsi
    push rcx
    push rdx

    mov rcx, size
    mov rsi, source
    mov rdi, destination

    cld
    repnz movsb

    pop rdx
    pop rcx
    pop rsi
    pop rdi
    %undef source
    %undef destination
    %undef size
    leave
    ret 24
;-------------------------------------------
replace_in_buffer:
    push rsi
    push rdi
    push rbx
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
    push r12

    mov rdi, buffer_of_text
    call GetStrlen
    mov r10, rdx           ; len of text file is in r10
    mov rsi, buffer_of_text  
    
    mov rdi, searched_word
    call GetStrlen
    mov r11, rdx              ; len of searched word is in r11

    mov rdi, new_replace_word
    call GetStrlen              ; len of new word is in rdx
    

    mov rdi, temp_buffer
    mov r12, replace_indexes    ; array contains replacing indexes
    mov r9, 0
    mov rcx, 0

    loop_replace:         ; copy all except given index in rax
        cmp rcx, r10               ; if end of file is arrived
        je  exit_replace_in_buffer
        cmp rcx, [r12]             ; if pointer is in a replace index now
        je replace_word
        mov bl, [rsi]
        mov [rdi], bl
        inc rsi
        inc rdi
        inc rcx
        jmp loop_replace

    replace_word:        ; replace given word in given index
        add rcx, r11     ; point to after this word
        add rsi, r11     ; point to after this word in text file
        add r12, 8       ; point to next replace index
        mov r8, new_replace_word
        mov r9, 0 

        loop_replace2: 
            cmp r9, rdx
            je  loop_replace  ; new word has replaced in this index successfully
            mov bl, [r8]
            mov [rdi], bl
            inc r8
            inc rdi
            inc r9
            jmp loop_replace2


    exit_replace_in_buffer:
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        pop rdx
        pop rcx
        pop rbx
        pop rdi
        pop rsi
        ret
;-------------------------------------------
write_temp:
    enter 0, 0
    %define  file qword[rbp+16]
    %define  buffer qword[rbp+24]
    push rax
    push rdi
    push rsi
    push rdx
    push r8

    mov rdi, file         ; delete previous temp file to avoid rewriting
    call deleteFile

    mov rdi, buffer
    call GetStrlen
    mov r8, rdx

    mov rax, 2 ; sys_open
    mov rdi, file
    mov rsi, O_CREAT | O_WRONLY    ; create if not exist
    mov rdx, 0o666
    ; xor rdx, rdx ; mode parameter is ignored when opening a file
    syscall
    mov [filehandle], rax

    ; Write the message to the end of the file
    mov rax, sys_write ; sys_write
    mov rdi, [filehandle]
    mov rsi, buffer
    mov rdx, r8 ; message length
    syscall

    pop r8
    pop rdx
    pop rsi
    pop rdi
    pop rax
    %undef buffer
    %undef file
    leave
    ret 16 
;-------------------------------------------
show_menu:
    push rsi

    mov rsi, menu_option_messages
    call printString
    call newLine
    
    mov rsi, menu_option_exit
    call printString
    call newLine

    mov rsi, menu_option_show
    call printString
    call newLine

    mov rsi, menu_option_report
    call printString
    call newLine

    mov rsi, menu_option_search
    call printString
    call newLine

    mov rsi, menu_option_replace
    call printString
    call newLine

    mov rsi, menu_option_append
    call printString
    call newLine

    mov rsi, menu_option_delete
    call printString
    call newLine

    mov rsi, menu_option_save
    call printString
    call newLine

    mov rsi, menu_option_saveas
    call printString
    call newLine

    mov rsi, menu_option_choose
    call printString
    call OneSpace

    pop rsi
    ret

;-------------------------------------------
f_show:
    push rsi
    push rax

    call f_open_and_read_file
    cmp rax, -1
    je exit_f_show

    show_context:                      ; print the file's context
        call OneLine
        mov rsi, show_context_message
        call printString
        call newLine
        mov rsi, buffer_of_text

        loop_show:
            mov al, [rsi]
            cmp al, 0
            je  exit_f_show
            call putc
            inc rsi
            jmp loop_show

    exit_f_show:
        call newLine
        call OneLine
        pop rax
        pop rsi
        ret
;-------------------------------------------
f_report:
    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9

    call f_open_and_read_file
    cmp rax, -1
    je exit_f_report

    call OneLine
    mov rdi, buffer_of_text

    call GetStrlen
    mov rsi, num_of_char_message
    call printString
    mov rax, rdx
    call writeNum
    call newLine

    mov rsi, buffer_of_text
    mov rcx, rdx              ; number of chars in buffer
    mov rdx, 0                ; number of chars in a single word
    mov r8, 0                 ; num of lines
    mov r9, 0                 ; num of words
    loop_count_lines:
        cmp rcx, 0
        je  fix_result
        mov al, [rsi]
        inc rsi
        dec rcx
        cmp al, NL
        je  inc_line
        cmp al, Space
        je inc_word
        inc rdx
        jmp loop_count_lines

    inc_line:
        inc r8
        cmp rdx, 0
        je  loop_count_lines
        inc r9               ; word ends with new line
        mov rdx, 0           ; free current word
        jmp loop_count_lines

    inc_word:
        cmp rdx, 0
        je  loop_count_lines     ; no new word is seen
        mov rdx, 0
        inc r9
        jmp loop_count_lines

    fix_result:            ; add result of last line
        cmp rdx, 0
        je show_result
        inc r8
        inc r9

    show_result:
        mov rsi, num_of_word_message
        call printString
        mov rax, r9
        call writeNum
        call newLine
        mov rsi, num_of_line_message
        call printString
        mov rax, r8
        call writeNum
        call newLine
        call OneLine
        call newLine 


    exit_f_report:
        pop r9
        pop r8
        pop rcx
        pop rdx
        pop rsi
        pop rdi
        pop rax
        ret
;-------------------------------------------
f_search:
    push rax
    push r15
    push rsi

    call f_sub_search             ; get the word, search it in file and save founded indexes in an array
    call OneLine
    mov rax, r15                  ; total number of appearance is in r15
    mov rsi, total_word_message   ; print number of total founded words
    call printString
    call writeNum
    call newLine
    call show_search_result
    call OneLine
    call newLine
    push 1000
    push searched_word
    call f_free           ; free the word
    push 1000
    push result_of_search  ; free result array
    call f_free_8byte

    exit_f_search:
        pop rsi
        pop r15
        pop rax
        ret
;-------------------------------------------
f_replace:
    push rsi
    push rdi
    push rax
    push rcx
    push rdx

    call OneLine
    call newLine

    call f_sub_search

    mov rsi, replace_search_newWord_message   ; get the word which user wants to replce old word with
    call printString
    call input_string

    mov rdi, replace_indexes  
    mov rsi, result_of_search
    mov rcx, 0
    loop_show_indexes:        ; show indexes which are contains given word
        cmp rcx, r15
        je replace
        push rsi
        mov rsi, replace_search_word_message
        call printString
        call OneSpace
        pop rsi
        mov rdx, [rsi]
        mov rax, [rsi]        ; show appeared index
        call writeNum
        call OneSpace
        push rsi
        mov rsi, replace_search_index_message
        call printString
        call OneSpace
        pop rsi
        add rsi, 8
        inc rcx
        call readNum        ; check if user wants to replace it
        call newLine
        cmp rax, 1
        jne loop_show_indexes
        mov [rdi], rdx          ; add to replace indexes if user wants to replace it
        add rdi, 8
        jmp loop_show_indexes
        
    replace:
        call replace_in_buffer     ; replace old and new words in text file buffer
        mov rsi, temp_buffer
        mov rdi, temp_file
        push rsi
        push rdi
        call write_temp            ; write new file in a temp file before saving

    exit_replace:   
        call OneLine           ; free all used buffers
        call newLine
        push 1000
        push searched_word
        call f_free   
        push 1000
        push new_replace_word
        call f_free   
        push 1000000
        push temp_buffer
        call f_free   
        push 1000
        push result_of_search
        call f_free_8byte 
        push 1000
        push replace_indexes
        call f_free_8byte 
        pop rdx
        pop rcx
        pop rax
        pop rdi
        pop rsi
        ret
;-------------------------------------------
f_append:
    push rax
    push rsi
    push rdi

    call f_open_and_read_file   ; check for old open files and open and read the file
    cmp rax, -1
    je exit_f_append

    mov rdi, buffer_of_text
    call GetStrlen
    push rdx             ; size of copy
    push temp_buffer
    push buffer_of_text
    call copy_buffer        ; copy text file to temp file

    mov rsi, append_message
    call printString
    call newLine
    call input_text 
    mov rsi, temp_buffer
    mov rdi, temp_file
    push rsi
    push rdi
    call write_temp

    exit_f_append:
        push 1000000
        push temp_buffer
        call f_free
        pop rdi
        pop rsi
        pop rax
        ret
;-------------------------------------------
f_delete:
    push rax
    push rsi
    push rdi
    push rdx
    call f_open_and_read_file   ; check for old open files and open and read the file
    cmp rax, -1
    je exit_f_delete

    mov rsi, delete_message
    call printString
    call readNum
    call newLine
    
    mov rdi, buffer_of_text
    call GetStrlen
    sub  rdx, rax        ; num of chars that should be remained

    push rdx
    push temp_buffer
    push buffer_of_text
    call copy_buffer    ; copy number of remained chars to temp buffer
    mov rsi, temp_buffer
    mov rdi, temp_file
    push rsi
    push rdi
    call write_temp
    
    exit_f_delete:
        push 1000000
        push temp_buffer
        call f_free
        pop rdx
        pop rdi
        pop rsi
        pop rax
        ret
;-------------------------------------------
f_save:
    push rdi
    push rsi
    push rax
    push rdx
    open_filesave:                       ; open text file
        mov rdi, temp_file
        call openFile
        mov [FD_txt], rax

    readTextFilesave:                    ; read context of text file
        mov  rdi, [FD_txt]
        mov  rsi, temp_buffer
        mov  rdx, 1000000
        call readFile

    mov rsi, temp_buffer
    mov rdi, file_dir
    push rsi
    push rdi
    call write_temp
    push 1000000
    push temp_buffer
    call f_free
    pop rdx
    pop rax
    pop rsi
    pop rdi
    ret
;-------------------------------------------
f_saveas:
    ret
;-------------------------------------------
global _start

_start:
    
    mov rax, 1                          ; exit code option

    Loop_menu:
        call show_menu                  ; show the menu 
        call readNum                   ; get the users option

        cmp rax, 0                     ; if user entered exit go to exit
        je  file_exit

        cmp rax, 1                     ; if user entered show context
        je  file_show

        cmp rax, 2                    ; if user entered report
        je  file_report

        cmp rax, 3                     ; if user entered search 
        je  file_search

        cmp rax, 4                     ; if user entered replace
        je  file_replace

        cmp rax, 5                     ; if user entered append
        je  file_append

        cmp rax, 6                     ; if user entered delete
        je  file_delete

        cmp rax, 7                     ; if user entered save
        je  file_save

        cmp rax, 8                     ; if user entered saveas
        je  file_saveas

        jmp Invalid_choice             ; else: users choice is not valid

    file_exit:
        jmp Exit
    
    file_show:
        call f_show
        jmp Loop_menu

    file_report:
        call f_report
        jmp Loop_menu

    file_search:
        call f_search
        jmp Loop_menu

    file_replace:
        call f_replace
        jmp Loop_menu

    file_append:
        call f_append
        jmp Loop_menu

    file_delete:
        call f_delete
        jmp Loop_menu

    file_save:
        call f_save
        jmp Loop_menu

    file_saveas:
        call f_saveas
        jmp Loop_menu

    Invalid_choice:
        push rsi
        mov rsi, invalid_option
        call printString
        call newLine
        pop rsi
        jmp Loop_menu


            
    Exit:
        mov ebx, 1
        mov eax, 0
        int 80h