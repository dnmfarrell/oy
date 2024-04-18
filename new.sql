drop table if exists task_tag;
create table task_tag (
  key integer primary key autoincrement,
  txt varchar(255) not null,
  t timestamp default (datetime('now')),
  cargo varchar(255),
  task_key integer not null,
  set_name integer not null
);
drop index if exists idx_task_set;
create index idx_task_set on task_tag (task_key, set_name);

drop view if exists vw_task_tags;
create view vw_task_tags as
select  tt.task_key,
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
order by tt.task_key, tt.set_name
;

drop view if exists vw_open_tasks;
create view vw_open_tasks as
select  task_key,
        group_concat(case when set_name = 'version' then cargo else '' end,'') description,
        min(t) created,
        max(t) updated,
        (strftime('%s', 'now') - strftime('%s',max(t))) / 86400 as days_old,
        group_concat(set_name||':'||tag_txt) tags
from vw_task_tags
group by 1
having sum(case when set_name = 'status' and tag_txt = 'open' then 1 else 0 end) = 1
;

drop view if exists vw_next_version;
create view vw_next_version as
select tag_txt+1, task_key, set_name
from vw_task_tags
where set_name = 'version'
;

drop view if exists vw_done_tasks;
create view vw_done_tasks as
select  task_key,
        group_concat(case when set_name = 'version' then cargo else '' end,'') description,
        group_concat(case when set_name = 'repeat' and tag_txt = 'on' then cargo else '' end,'') repeat,
        min(t) created,
        max(case when set_name = 'status' then t else 0 end) completed,
        (strftime('%s', 'now') - strftime('%s',max(t))) / 86400 as days_old,
        group_concat(set_name||':'||tag_txt) tags
from vw_task_tags
group by 1
having sum(case when set_name = 'status' and tag_txt = 'done' then 1 else 0 end) = 1
;

drop view if exists vw_repeat_tasks;
create view vw_repeat_tasks as
with recursive split(task_key, repeat_pat, rest) as (
  select task_key, '', repeat||',' as rest
  from vw_done_tasks
  where date(completed, 'localtime') != date('now', 'localtime') and repeat != ''
  union all
  select task_key, substr(rest, 0, instr(rest, ',')), substr(rest, instr(rest, ',')+1)
  from split where rest!=''
)
select distinct task_key
from split
where strftime('%Y-%m-%d %w', 'now', 'localtime') like repeat_pat
;
