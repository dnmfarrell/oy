drop table if exists "set";
create table "set" (
  key integer primary key autoincrement,
  name varchar(255) not null,
  unique (name)
);
insert into "set" (name) values
('version'),
('status');

drop table if exists task;
create table task (
  key integer primary key autoincrement,
  txt varchar(255) not null
);

drop table if exists task_tag;
create table task_tag (
  key integer primary key autoincrement,
  txt varchar(255) not null,
  t timestamp default (datetime('now')),
  cargo varchar(255),
  task_key integer not null references task (key),
  set_key integer not null references "set" (key)
);

drop view if exists vw_task_tags;
create view vw_task_tags as
select  tt.task_key,
        tt.t,
        datetime(tt.t, 'localtime') lt,
        tt.set_key,
        "set".name set_name,
        tt.txt tag_txt
from task_tag tt
join "set" on "set".key = tt.set_key
left join task_tag st
on st.task_key = tt.task_key
  and st.set_key = tt.set_key
  and st.key > tt.key
where st.task_key is null
order by tt.task_key, tt.set_key
;

drop view if exists vw_open_tasks;
create view vw_open_tasks as
select  task_key,
        min(t) created,
        max(t) updated,
        min(lt) created_l,
        max(lt) updated_l,
        group_concat(set_name||':'||tag_txt) tags
from vw_task_tags
group by 1
having sum(case when set_name = 'status' and tag_txt = 'open' then 1 else 0 end) = 1
;

drop view if exists vw_done_tasks;
create view vw_done_tasks as
select  task_key,
        min(t) created,
        max(t) updated,
        min(lt) created_l,
        max(lt) updated_l,
        group_concat(set_name||':'||tag_txt) tags
from vw_task_tags
group by 1
having sum(case when set_name = 'status' and tag_txt = 'done' then 1 else 0 end) = 1
;

drop view if exists vw_next_version;
create view vw_next_version as
select tag_txt+1, task.txt, task_key, set_key
from vw_task_tags
join task on key = task_key
where set_key = 1
;
