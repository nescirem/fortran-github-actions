#!/usr/bin/env python
#coding:utf-8

from sh import bash

def createDeck():
    import itertools
    DDBUG=['debug','release']
    FC=['gfortran']
    return (list(itertools.product(FC,DDBUG)))

def main():
    
    def test_library(str):
        expected = read_file("./expect/expect.txt")            
        expected = pure_str(expected)
        cstrs = str.split( " --------------------------------" )
        result = pure_str(cstrs[-2])

        if expected == result:
            print ('\033[0;32m[PASS]\033[0m', flush=True);  err_code = 0
        else:
            print ('\033[1;31m[ERROR]\033[0m', flush=True);  err_code = 1
        
        return err_code
        
    def test_modes():
        err_count=0
        for i in modes:
            bash( c='make clean', _timeout=2 )
            app_cmd = i[0]+' '+i[1]
            if app_cmd.isspace():
                print ('DEFAULT', end=": ", flush=True)
            else:
                print ( app_cmd, end=": ", flush=True)
            str = bash( c='./build.sh '+app_cmd, _timeout=10 )
            err_count += test_library(str)
        return err_count
    
        
    print ('', flush=True)
    
    err_tcount = 0
    
    # Fortran STATIC LIBRARY
    modes = createDeck()
    modes.append(('',''))
    err_tcount += test_modes()
    print ('', flush=True)
    
    
    clean_all()
    
    print ("\033[1;31mERROR\033[0m =", err_tcount)
    print ('', flush=True)
    
def read_file(file_path):
    import os
    if not os.path.isfile(file_path):
        raise TypeError(file_path + " does not exist")
    text_in_file = open(file_path).read()
    return text_in_file
    
def pure_str(str):
    purestr = str.replace(' ','')
    purestr = purestr.replace('\n','')
    return purestr
    
def clean_all():
    bash( c="make clean", _timeout=2 )
    #------------------------------------------------------
    # add script here
    #------------------------------------------------------
    print ('', flush=True)
    
if __name__=="__main__":
    main()

