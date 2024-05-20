drop view if exists vw_task_sets_last;
create view vw_task_sets_last as
select  tt.rowid as key,
        tt.task_id,
        tt.t,
        datetime(tt.t, 'localtime') lt,
        tt.set_name,
        tt.set_value tag_txt,
        tt.cargo
from task tt
left join task st
on st.task_id = tt.task_id
  and st.set_name = tt.set_name
  and st.rowid > tt.rowid
where st.task_id is null
order by tt.task_id, tt.set_name;

drop view if exists vw_task_sets_first;
create view vw_task_sets_first as
select  tt.rowid as key,
        tt.task_id,
        tt.t,
        datetime(tt.t, 'localtime') lt,
        tt.set_name,
        tt.set_value tag_txt,
        tt.cargo
from task tt
left join task st
on st.task_id = tt.task_id
  and st.set_name = tt.set_name
  and st.rowid < tt.rowid
where st.task_id is null
order by tt.task_id, tt.set_name;

drop view if exists vw_task_sets_first_and_last;
create view vw_task_sets_first_and_last as
select key from vw_task_sets_first
union
select key from vw_task_sets_last
order by key;

drop view if exists vw_tasks;
create view vw_tasks as
select  task_id,
        group_concat(case when set_name = 'version' then cargo else '' end,'') description,
        sum(case when set_name = 'priority' then cargo else 0 end) priority,
        group_concat(case when set_name = 'repeat' and tag_txt != 'off' then cargo else null end,'') repeat_sched,
        group_concat(case when set_name = 'status' and tag_txt = 'done' then cargo else null end,'') repeat_next,
        min(t) created,
        max(t) updated,
        max(case when set_name = 'status' and tag_txt = 'done' then t else null end) completed,
        group_concat(case when set_name != 'tags' then set_name||':'||tag_txt else null end) props,
        ','||group_concat(case when set_name != 'tags' then set_name||':'||tag_txt else null end)||',' props_match,
        group_concat(case when set_name = 'tags' then tag_txt else '' end,'') tags,
        ','||group_concat(case when set_name = 'tags' then tag_txt else '' end,'')||',' tags_match
from vw_task_sets_last
where tag_txt != ''
group by 1
order by priority desc;

drop view if exists vw_next_version;
create view vw_next_version as
select tag_txt+1, task_id, set_name
from vw_task_sets_last
where set_name = 'version';

drop view if exists vw_tags;
create view vw_tags as
with recursive split(task_id, tag, rest) as (
  select task_id, '', tag_txt||',' as rest
  from vw_task_tags_last
  where set_name = 'tags'
  union all
  select task_id, substr(rest, 0, instr(rest, ',')), substr(rest, instr(rest, ',')+1)
  from split where rest!=''
)
select distinct task_id, tag
from split
where tag != ''
order by 1;

drop view if exists vw_dates;
create view vw_dates as
with recursive dates(day, year, mon, dow) as (
  select strftime('%Y-%m-01', 'now') as day,
         strftime('%Y', 'now', '+1 day'),
         strftime('%m', 'now', '+1 day'),
         strftime('%w', 'now', '+1 day')
  union all
  select date(day, '+1 day'), 
         strftime('%Y', day, '+1 day'),
         strftime('%m', day, '+1 day'),
         strftime('%w', day, '+1 day')
  from dates
  where day < date('now', '+396 days')
)
select * from (
  select day,
         dow,
         cast(rank()over(partition by year, mon, dow order by day) as varchar(1)) down,
         case when rank()over(partition by year, mon, dow order by day desc) = 1
              then true else false end as dowl
  from dates
) x
where strftime('%s', day) >  strftime('%s', date('now'))
  and strftime('%s', day) <= strftime('%s', date('now', '+1 year'))
order by day;

drop view if exists vw_repeat_tasks;
create view vw_repeat_tasks as
select task_id
from vw_tasks
where completed is not null
      and date(completed, 'localtime') != date('now', 'localtime')
      and repeat_next = date('now', 'localtime');

drop view if exists vw_repeat_dows;
create view vw_repeat_dows as
with recursive split(task_id, day, dow, dow_rest) as (
  select task_id,
    substr(repeat_sched, 1, instr(repeat_sched, ' ') -1) day,
    '' dow,
    substr(repeat_sched, instr(repeat_sched, ' ')+1, instr(substr(repeat_sched, instr(repeat_sched, ' ')+1),' ')-1) dow_rest
  from vw_tasks
  where repeat_sched != ''
  union all
  select task_id, day, substr(dow_rest, 1, 1), substr(dow_rest,2)
  from split where dow_rest!=''
)
select task_id, day, dow
from split
where dow != ''
order by 1, 2;

drop view if exists vw_repeat_downs;
create view vw_repeat_downs as
with recursive split(task_id, day, down, down_rest) as (
  select task_id,
    substr(repeat_sched, 1, instr(repeat_sched, ' ') -1) day,
    '' down,
    substr(repeat_sched, 1 + instr(repeat_sched, ' ') + instr(substr(repeat_sched, instr(repeat_sched, ' ')+1),' ')) down_rest
  from vw_tasks
  where repeat_sched != ''
  union all
  select task_id, day, substr(down_rest, 1, 1), substr(down_rest,2)
  from split where down_rest!=''
)
select task_id,
       day,
       case when down != 'L' then down else '' end down,
       case when down = 'L' then true else false end dowl
from split
where down != ''
order by 1, 2;

drop view if exists vw_repeat_next;
create view vw_repeat_next as
select d.task_id, da.day
from vw_repeat_dows d
cross join vw_repeat_downs n using (task_id)
join vw_dates da on
  da.day like d.day
  and da.dow like d.dow
  and (da.down like n.down or da.dowl = true and n.dowl = true)
order by da.day limit 1;
