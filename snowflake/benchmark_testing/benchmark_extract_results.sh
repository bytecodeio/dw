#
# NAME: 
#   benchmart_extract_results.sh script
# DESCRIPTION: 
#  This script extracts the lines with start time, end time, and time to run a query
#  from the output logs of the benchmark SQLs to be tested.
# 
# pattern 'START ':
# If "=====..."" line is present in output log, then print 4 lines before 'START ', else 3 lines is fine.
#
# pattern 'END ':
# Prints 4 lines before + 1 next line. The 4th line (before 'END ') is the one with 'Rows(s) produced...Time elapsed.'
#
# Print the status of warehouse before extracting benchmarks. Copy the complete log file.
awk '{print;}' op_status_warehouse.log >> benchmark_stats.log


# SQL: 204
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_204.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_204.log >> benchmark_stats.log
# SQL: 205 
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_205.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_205.log >> benchmark_stats.log
# SQL: 206 
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_206.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_206.log >> benchmark_stats.log
# SQL: 102047
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102047.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102047.log >> benchmark_stats.log

# SQL: 102058 
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102058.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102058.log >> benchmark_stats.log

# SQL: 102060 
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102060.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102060.log >> benchmark_stats.log

# SQL: 102070 
awk '/START /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102070.log >> benchmark_stats.log
awk '/END /{for(i=1;i<=x;)print a[i++];print; getline; print}
             {for(i=1;i<x;i++)a[i]=a[i+1];a[x]=$0;}'  x=4 op_102070.log >> benchmark_stats.log

