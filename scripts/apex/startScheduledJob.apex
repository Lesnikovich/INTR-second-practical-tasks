String cronExp = '0 40 10 * * ?';
System.schedule('Daily Outdated Contacts Schedule', cronExp, new DailyOutdatedContactsSchedule());
