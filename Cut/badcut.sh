#!/bin/sh

USAGE=' badcut [-d delimiter] [-f from] [-t to] [-s] [file]..'
IFS="-" #make the shell delimiter "-" for reading command line arguments
# Setting default values for given commandline arguments
delimiter=$'\t' # tab character
frnumber=0      # first field
tonumber=100    # final field (arbitrary large number)
s_exists=1      # 1 indicates -s not given, 5 indicates otherwise

#If no input is given, exit with error
#if [ "$1" = "" ]
#   then   #are you sure it is really an error and not simply move on with commands and exit 0? DELETE LATER!!
#          #or is it just reading from input
#   echo "ERROR! No Argument!"
#   exit 1
#fi

# Read Command-Line arguments till there are none left
# or break out of loop once it is a file. 
while [ $# -gt 0 ] # ; is needed only if do is on the same line. Same goes for if, case, for
do    
   #If argument is not a valid command, break
   case $1 in 
      [!-]*)
      break
   esac
  
# Note: shift are used in -d, -t and -f to ensure next call 
#       of while loop is not their arguments.

   # If -d is given, set delimiter value
   if [ "$1" = "-d" ]
      then
      delimiter_exist=2 # to set delimiter which is the following argument
      delimiter=${!delimiter_exist}    
      if [ "$delimiter" != $'\t' ] # to ensure d is not it's default tab value
         then
         case $delimiter in
         [!-]*)
         shift
         ;;
         [-]*) #if the next argument is a command instead
         delimiter=$'\t' #restore delimiter's default value
         ;;
         esac
      fi
   
   # If -f is given, set frnumber value
   # assuming -f will always have a valid argument
   elif [ "$1" = "-f" ]
      then
      from_exist=2
      frnumber=${!from_exist}
      frnumber=`expr $frnumber - 1` 
      shift 
   
   # If -t is given, set tonumber value
   # assuming -t will always have a valid argument
   elif [ "$1" = "-t" ]
      then
      to_exist=2
      tonumber=${!to_exist}
      tonumber=`expr $tonumber - 1`
      shift 

   # If -s is given, set s_exists=5 to indicate that
   # command -s was received
   elif [ "$1" = "-s" ]
      then
      s_exists=5 
   
   # If an invalid argument was given. 
   # Terminate program with failure
   else
      echo "Invalid Arguments!"
      echo $USAGE
      exit 1
   fi
shift
done

# set IFS according to given delimiter
IFS=$delimiter

# If we are here, it means there are no arguments left or the file has begun
# DEFAULTS: delimiter=$'\t' ; frnumber=1 ; tonumber=100 ; s_exists=1 (5 if it exist)

# To test if frnumber > tonumber, if it is
# exit normally without printing anything
diffnumber=`expr $tonumber - $frnumber`
if [ $diffnumber -lt 0 ]; then
   exit 0
fi

if [ $frnumber -le -1 ] && [ $tonumber -le -1 ]; then
   exit 0
fi

# If we are here, it means that frnumber <= tonumber

case $# in
 [!0]) 
   # If there are arguments left, read them.
   # and execute badcut on each of them. 
   while [ $# -gt 0 ] 
   do 
      #check if argument is a file, 
      if [ -e $1 ]
      then     
         # It is a file, execute badcut function on file
         while read line
         do
            
            # if -s command was given
            # append lines with delimiter only
            if [ $s_exists = 5 ]; then # 
                if [[ "$line" == *${delimiter}* ]] 
                   then
                   echo "$line" >> new_file1               
                fi
 
            # if -s command was not given
            # append all lines
            else 
                echo "$line" >> new_file1
            fi
         done < "$1"

        i=0 # used in testing conditions during iterations
        lenlines=0 # to count number of fields in each line

        while read line2
        do
           # Count number of fields in line
           for y in $line2; do
              lenlines=`expr $lenlines + 1`
           done       
        
           # Deduct 1 from number of fields 
           # since index starts from 0
           lenlines=`expr $lenlines - 1` 
           
           # echo the required fields out to stdout
           for x in $line2; do
              if [ $i -eq $lenlines ]; then #condition for last field if its needed
                 if [ $i -le $tonumber ]; then
                    echo "$x\c" #echo the field without the delimiter
                 fi
                 echo "\n\c"
              elif [ $i -lt $frnumber ] || [ $i -gt $tonumber ]; then #condition for not needed fields
                 i=`expr $i + 1`
                 continue
              else #if fulfill condition, echo the field with the delimiter
                 echo "$x\c" $delimiter
              fi
              i=`expr $i + 1`
           done
       # reset values for next line
       i=0
       lenlines=0
       done < new_file1
       rm new_file1

      # If invalid file given, exit with error
      else
         echo "ERROR! File \"$1\" Does Not Exist!"
         exit 1 
      fi
   shift
   done
   exit 0 # Exit success without reading from input
   ;;
[0])
   # If there are no arguments left, read from stdin
   # and execute badcut on stdin
   
   # while the user hasn't hit ctrl+d
   while read line
     do
     touch new_file1 # make a new file to store input
     # if -s command was given
     # append lines with delimiter only
     if [ $s_exists = 5 ]; then # 
        if [[ "$line" == *${delimiter}* ]] 
          then
          echo "$line" >> new_file1               
        fi
 
     # if -s command was not given
     # append all lines
     else 
                echo "$line" >> new_file1
            fi

     i=0 # used in testing conditions during iterations
     lenlines=0 # to count number of fields in each line
     while read line2
       do
       # Count number of fields in line
       for y in $line2; do
         lenlines=`expr $lenlines + 1`
       done       
        
       # Deduct 1 from number of fields 
       # since index starts from 0
       lenlines=`expr $lenlines - 1` 
           
       # echo the required fields out to stdout
         for x in $line2; do
           if [ $i -eq $lenlines ]; then
             if [ $i -le $tonumber ]; then
               echo "$x\c"
             fi
           echo "\n\c"
           elif [ $i -lt $frnumber ] || [ $i -gt $tonumber ]; then
           i=`expr $i + 1`
             continue
           else
             echo "$x\c" $delimiter
           fi
         i=`expr $i + 1`
         done

       # reset values for next line
       i=0
       lenlines=0
     done < new_file1
     rm new_file1 # remove the file for next input
   done < /dev/stdin
       rm new_file1
exit 0
esac
