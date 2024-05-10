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
        group_concat(case when set_name = 'repeat' and tag_txt = 'on' then cargo else '' end,'') repeat,
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

drop view if exists vw_repeat_tasks;
create view vw_repeat_tasks as
with recursive split(task_id, repeat_pat, rest) as (
  select task_id, '', repeat||',' as rest
  from vw_tasks
  where completed is not null
        and date(completed, 'localtime') != date('now', 'localtime') and repeat != ''
  union all
  select task_id, substr(rest, 0, instr(rest, ',')), substr(rest, instr(rest, ',')+1)
  from split where rest!=''
)
select distinct task_id
from split
where strftime('%Y-%m-%d %w', 'now', 'localtime') like repeat_pat;

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
