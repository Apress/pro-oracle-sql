--- ILO Execution in a Single Session 

exec ilo_timer.set_mark_all_tasks_interesting(TRUE,TRUE);

exec ilo_task.begin_task('Month-end','Purchasing'); 

@purchasing_report 

exec ilo_task.end_task;

