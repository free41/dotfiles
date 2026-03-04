← [[<% tp.date.now("YYYY-MM-DD", -1, tp.file.title, "YYYY-MM-DD") %>]] | [[<% tp.date.now("YYYY-MM-DD", 1, tp.file.title, "YYYY-MM-DD") %>]] →

---
# Journal



---

# Key Tasks

```tasks
((not done) AND (scheduled on or before <%tp.file.title%>)) OR (done on <%tp.file.title%>) OR (due on <%tp.file.title%>)
sort by status, scheduled
hide scheduled date
group by priority
hide priority
```


---
# Upcoming Tasks

```tasks
((not done) AND (due on or before <%tp.date.now("YYYY-MM-DD", 7, tp.file.title, "YYYY-MM-DD")%>)) 
sort by status, scheduled
hide scheduled date
group by priority
hide priority
```


