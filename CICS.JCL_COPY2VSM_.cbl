//COPYSEQ JOB CLASS=A,MSGCLASS=X                     
//*                                                  
//* COPY SEQENTIAL DATASET INTO VSAM CLUSTER         
//*                                                  
//DEFCLS EXEC PGM=IDCAMS,REGION=4096K                
//SEQDD DD DSN=U0210.SEQDAT.CBLBANK,DISP=SHR           
//VSAMDD DD DSN=U0210.VSAM.CBLBANK,DISP=SHR            
//SYSPRINT DD SYSOUT=A                               
//SYSIN DD *                                         
  REPRO INFILE(SEQDD) -                              
        OUTFILE(VSAMDD)                              
/*                                                   