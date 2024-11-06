public class DailyOutdatedContactsSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DailyOutdatedContactsBatch(), 200);
    }
}