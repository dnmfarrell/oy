drop view if exists vw_task_tags_last;
create view vw_task_tags_last as
select  tt.key,
        tt.task_key,
        tt.t,
        datetime(tt.t, 'localtime') lt,
        tt.set_name,
        tt.txt tag_txt,
        tt.cargo
from task_tag tt
left join task_tag st
on st.task_key = tt.task_key
  and st.set_name = tt.set_name
  and st.key > tt.key
where st.task_key is null
order by tt.task_key, tt.set_name;

drop view if exists vw_task_tags_first;
create view vw_task_tags_first as
select  tt.key,
        tt.task_key,
        tt.t,
        datetime(tt.t, 'localtime') lt,
        tt.set_name,
        tt.txt tag_txt,
        tt.cargo
from task_tag tt
left join task_tag st
on st.task_key = tt.task_key
  and st.set_name = tt.set_name
  and st.key < tt.key
where st.task_key is null
order by tt.task_key, tt.set_name;

drop view if exists vw_task_tags_first_and_last;
create view vw_task_tags_first_and_last as
select key from vw_task_tags_first
union
select key from vw_task_tags_last
order by key;

drop view if exists vw_tasks;
create view vw_tasks as
select  task_key,
        group_concat(case when set_name = 'version' then cargo else '' end,'') description,
        sum(case when set_name = 'priority' then cargo else 0 end) priority,
        group_concat(case when set_name = 'repeat' and tag_txt = 'on' then cargo else '' end,'') repeat,
        min(t) created,
        max(t) updated,
        max(case when set_name = 'status' and tag_txt = 'done' then t else null end) completed,
        (strftime('%s', 'now') - strftime('%s',max(t))) / 86400 as days_old,
        group_concat(set_name||':'||tag_txt) props
from vw_task_tags_last
where tag_txt != ''
group by 1
order by priority desc;

drop view if exists vw_open_tasks;
create view vw_open_tasks as
select  task_key,
        description,
        cast(days_old as varchar) || case when days_old = 1 then ' day' else ' days' end as age,
        props
from vw_tasks
where completed is null;

drop view if exists vw_done_tasks;
create view vw_done_tasks as
select  task_key,
        description,
        completed,
        cast(days_old as varchar) || case when days_old = 1 then ' day' else ' days' end as age,
        props
from vw_tasks
where completed is not null;

drop view if exists vw_next_version;
create view vw_next_version as
select tag_txt+1, task_key, set_name
from vw_task_tags_last
where set_name = 'version';

drop view if exists vw_repeat_tasks;
create view vw_repeat_tasks as
with recursive split(task_key, repeat_pat, rest) as (
  select task_key, '', repeat||',' as rest
  from vw_tasks
  where completed is not null
        and date(completed, 'localtime') != date('now', 'localtime') and repeat != ''
  union all
  select task_key, substr(rest, 0, instr(rest, ',')), substr(rest, instr(rest, ',')+1)
  from split where rest!=''
)
select distinct task_key
from split
where strftime('%Y-%m-%d %w', 'now', 'localtime') like repeat_pat;

drop view if exists vw_tags;
create view vw_tags as
with recursive split(task_key, tag, rest) as (
  select task_key, '', tag_txt||',' as rest
  from vw_task_tags_last
  where set_name = 'tags'
  union all
  select task_key, substr(rest, 0, instr(rest, ',')), substr(rest, instr(rest, ',')+1)
  from split where rest!=''
)
select distinct task_key, tag
from split
where tag != ''
order by 1;
