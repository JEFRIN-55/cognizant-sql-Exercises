-- 1. Users Table
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    city TEXT NOT NULL,
    registration_date DATE NOT NULL
);

-- 2. Events Table
CREATE TABLE Events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    city TEXT NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status TEXT CHECK(status IN ('upcoming','completed','cancelled')),
    organizer_id INTEGER,
    FOREIGN KEY (organizer_id) REFERENCES Users(user_id)
);

-- 3. Sessions Table
CREATE TABLE Sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER,
    title TEXT NOT NULL,
    speaker_name TEXT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- 4. Registrations Table
CREATE TABLE Registrations (
    registration_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    event_id INTEGER,
    registration_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- 5. Feedback Table
CREATE TABLE Feedback (
    feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    event_id INTEGER,
    rating INTEGER CHECK(rating BETWEEN 1 AND 5),
    comments TEXT,
    feedback_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- 6. Resources Table
CREATE TABLE Resources (
    resource_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER,
    resource_type TEXT CHECK(resource_type IN ('pdf','image','link')),
    resource_url TEXT NOT NULL,
    uploaded_at DATETIME NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);


-- USERS
INSERT INTO Users (full_name, email, city, registration_date)
VALUES
('Alice Johnson', 'alice@example.com', 'New York', '2024-12-01'),
('Bob Smith', 'bob@example.com', 'Los Angeles', '2024-12-05'),
('Charlie Lee', 'charlie@example.com', 'Chicago', '2024-12-10'),
('Diana King', 'diana@example.com', 'New York', '2025-01-15'),
('Ethan Hunt', 'ethan@example.com', 'Los Angeles', '2025-02-01');

-- EVENTS
INSERT INTO Events (title, description, city, start_date, end_date, status, organizer_id)
VALUES
('Tech Innovators Meetup',
 'A meetup for tech enthusiasts.',
 'New York',
 '2025-06-10 10:00:00',
 '2025-06-10 16:00:00',
 'upcoming',
 1),

('AI & ML Conference',
 'Conference on AI and ML advancements.',
 'Chicago',
 '2025-05-15 09:00:00',
 '2025-05-15 17:00:00',
 'completed',
 3),

('Frontend Development Bootcamp',
 'Hands-on training on frontend tech.',
 'Los Angeles',
 '2025-07-01 10:00:00',
 '2025-07-03 16:00:00',
 'upcoming',
 2);

-- SESSIONS
INSERT INTO Sessions (event_id, title, speaker_name, start_time, end_time)
VALUES
(1, 'Opening Keynote', 'Dr. Tech',
 '2025-06-10 10:00:00',
 '2025-06-10 11:00:00'),

(1, 'Future of Web Dev', 'Alice Johnson',
 '2025-06-10 11:15:00',
 '2025-06-10 12:30:00'),

(2, 'AI in Healthcare', 'Charlie Lee',
 '2025-05-15 09:30:00',
 '2025-05-15 11:00:00'),

(3, 'Intro to HTML5', 'Bob Smith',
 '2025-07-01 10:00:00',
 '2025-07-01 12:00:00');

-- REGISTRATIONS
INSERT INTO Registrations (user_id, event_id, registration_date)
VALUES
(1, 1, '2025-05-01'),
(2, 1, '2025-05-02'),
(3, 2, '2025-04-30'),
(4, 2, '2025-04-28'),
(5, 3, '2025-06-15');

-- FEEDBACK
INSERT INTO Feedback (user_id, event_id, rating, comments, feedback_date)
VALUES
(3, 2, 4, 'Great insights!', '2025-05-16'),
(4, 2, 5, 'Very informative.', '2025-05-16'),
(2, 1, 3, 'Could be better.', '2025-06-11');

-- RESOURCES
INSERT INTO Resources (event_id, resource_type, resource_url, uploaded_at)
VALUES
(1, 'pdf',
 'https://portal.com/resources/tech_meetup_agenda.pdf',
 '2025-05-01 10:00:00'),

(2, 'image',
 'https://portal.com/resources/ai_poster.jpg',
 '2025-04-20 09:00:00'),

(3, 'link',
 'https://portal.com/resources/html5_docs',
 '2025-06-25 15:00:00');

 /*
EVENT MANAGEMENT SYSTEM - SQL EXERCISES
ANSI SQL Using MySQL
*/

-- Question 1: User Upcoming Events
-- Show a list of all upcoming events a user is
-- registered for in their city, sorted by date.

select e.title
from events e
join registrations r
on e.event_id = r.event_id
join users u
on r.user_id = u.user_id
where e.city = u.city
and e.status = 'upcoming'
order by e.start_date;

-- Question 2: Top Rated Events
-- Identify events with the highest average rating,
-- considering only those with at least 10 feedbacks.

select e.title,
AVG(f.rating) as average_rating
from events e
join feedback f
on e.event_id = f.event_id
group by e.event_id, e.title
having count(f.feedback_id) >= 10
order by average_rating desc;


-- Question 3: Inactive Users
-- Retrieve users who have not registered for any
-- events in the last 90 days.

select u.full_name
from users u
left join registrations r
on u.user_id = r.user_id
and r.registration_date >= DATE('now', '-90 days')
where r.registration_id is null;


-- Question 4: Peak Session Hours
-- Count how many sessions are scheduled between
-- 10 AM and 12 PM for each event.

select e.title,
count(e.event_id)
from events e
join sessions s
on e.event_id = s.event_id
where TIME(s.start_time) >= '10:00:00'
and TIME(s.end_time) <= '12:00:00'
group by s.event_id;

-- Question 5: Most Active Cities
-- List top 5 cities with highest registrations.

select e.city,
count(e.event_id)
from events e
join registrations r
on e.event_id = r.event_id
group by e.city
order by count(r.event_id) DESC
limit 5;


-- Question 6: Event Resource Summary
-- Generate a report showing number of resources
-- uploaded for each event.

select count(r.resource_id),
e.title
from events e
left join resources r
on e.event_id = r.event_id
group by e.event_id;


-- Question 7: Low Feedback Alerts
-- List users who gave ratings less than 3.

select u.full_name,
f.comments,
e.title
from users u
join feedback f
on u.user_id = f.user_id
join events e
on f.event_id = e.event_id
where f.rating < '3';


-- Question 8: Sessions per Upcoming Event
-- Display upcoming events with session count.

select e.title,
count(s.event_id)
from events e
join sessions s
on e.event_id = s.event_id
where e.status = 'upcoming'
group by e.event_id;


-- Question 9: Organizer Event Summary
-- Show number of events created by each organizer.


select e.organizer_id,
count(event_id),
e.status
from events e
group by e.organizer_id,
e.status;


-- Question 10: Feedback Gap
-- Identify events that had registrations but
-- received no feedback at all.


select e.title
from events e
where e.event_id IN (
  select event_id
  from registrations
)
and e.event_id NOT IN (
  select f.event_id
  from feedback f
);



-- Question 11: Daily New User Count
-- Find the number of users who registered each day
-- in the last 7 days.


select registration_date,
count(user_id)
from users
where registration_date >= DATE('now', '-7days')
group by registration_date;



-- Question 12: Event with Maximum Sessions
-- List the event(s) with the highest number
-- of sessions.


select e.title
from events e
join sessions s
on e.event_id = s.event_id
group by e.event_id
order by count(s.event_id) DESC
limit 1;



-- Question 13: Average Rating per City
-- Calculate the average feedback rating of
-- events conducted in each city.


select e.city,
avg(f.rating) as averageRating
from events e
left join feedback f
on e.event_id = f.event_id
group by e.city;



-- Question 14: Most Registered Events
-- List top 3 events based on total number
-- of registrations.


select e.title,
count(e.event_id)
from events e
join registrations r
on e.event_id = r.event_id
group by e.event_id
order by count(r.event_id) DESC
limit 3;



-- Question 15: Event Session Time Conflict
-- Identify overlapping sessions within
-- the same event.


select e.title,
s1.session_id,
s2.session_id
from events e
join sessions s1
on e.event_id = s1.event_id
join sessions s2
on s1.event_id = s2.event_id
where s1.session_id <> s2.session_id
and s1.start_time < s2.end_time
and s1.end_time > s2.start_time;



-- Question 16: Unregistered Active Users
-- Find users who created an account in the
-- last 30 days but haven't registered for any events.


select u.full_name
from users u
where u.registration_date >= DATE('now', '-30days')
and u.user_id not in (
  select user_id
  from registrations
);



-- Question 17: Multi-Session Speakers
-- Identify speakers handling more than one
-- session across all events.


select speaker_name
from sessions
group by speaker_name
having count(session_id) >= 2;


-- Question 18: Resource Availability Check
-- List all events that do not have any resources uploaded.


select title
from events
where event_id not in (
  select event_id
  from resources
);



-- Question 19: Completed Events with Feedback Summary
-- For completed events, show total registrations
-- and average feedback rating.


select e.title,
count(distinct registration_id) as total_registrations,
avg(f.rating) as average_rating
from events e
join feedback f
on e.event_id = f.event_id
join registrations r
on e.event_id = r.event_id
where e.status = 'completed'
group by e.event_id;



-- Question 20: User Engagement Index
-- For each user, calculate how many events they
-- attended and how many feedbacks they submitted.


select u.full_name,
count(distinct r.event_id),
count(distinct f.event_id)
from users u
join registrations r
on u.user_id = r.user_id
left join feedback f
on u.user_id = f.user_id
group by u.user_id;


-- Question 21: Top Feedback Providers
-- List top 5 users who submitted the most feedback.


select u.full_name
from users u
join feedback f
on u.user_id = f.user_id
group by u.user_id
order by count(f.user_id) DESC
LIMIT 5;



-- Question 22: Duplicate Registrations Check
-- Detect if a user has been registered more than
-- once for the same event.


select u.full_name
from users
where u.user_id in (
  select user_id
  from registrations r
  group by event_id, user_id
  having count(*) > 1
);



-- Question 23: Registration Trends
-- Show month-wise registration count trend
-- over the past 12 months.


select strftime('%Y-%m', registration_date) as month,
count(*) as regCount
from registrations
group by strftime('%Y-%m', registration_date)
order by month;



-- Question 24: Average Session Duration per Event
-- Compute average duration (in minutes)
-- of sessions in each event.


select e.title,
avg((julianday(s.end_time) - julianday(s.start_time)) * 24 * 60)
from events e
join sessions s
on e.event_id = s.event_id
group by e.event_id;



-- Question 25: Events Without Sessions
-- List all events that currently have no sessions
-- scheduled under them.


select title
from events
where event_id not in (
  select event_id
  from sessions
);

