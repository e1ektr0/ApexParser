/*
*	Author: SLegostaev
*	The class for MEP_AgendaComponent component
*/
public with sharing class MEP_AgendaComponentController {


    public MEP_CalendarEventMeetingsDataProvider dp {get; set;}

    public List<AgentaMeeting> wrapper {get; set;}
    public Datetime agendaStartDate {get; set;}
    public String newDate{get;set;}
    private Integer agendaPeriod = MEP_ApplicationSettings.getIntegerValue('DEFAULT_AGENDA_PERIOD');
    public String errorMessage {get; set;}

    public Boolean isToDay {get; set;}

    public MEP_AgendaComponentController() {
        isToDay = false;

        //init start date for agenda
        if (agendaStartDate == null) {
            agendaStartDate = Datetime.now();
            isToDay = true;
        }

        //init data provider and data for agenda
        if (dp == null) {
            dp = new MEP_CalendarEventMeetingsDataProvider(new MEP_CalendarFilter());
            initAgenda();
        }
    }

    public void updateDate()
    {
    	agendaStartDate = MEP_DateTimeUtils.getDatetime(newDate, Datetime.now().format('hh:mm a'));
    	newDate=null;
    	initAgenda();
    }

    public Pagereference initAgenda() {
    	//create wrapper for meetings
        wrapper = new List<AgentaMeeting>();

        //init start date for agenda for first page load
        if (agendaStartDate == null) {
    		agendaStartDate = Datetime.now();
        }

        //get meetings for agenda period, agenda period getting from custom setting (7 by default)
        for (Integer i = 0; i < agendaPeriod; i++) {
        	//set start date to filter and get mettings for every date from agenda period
            dp.filter.startDate = agendaStartDate.addDays(i);
            List<MEP_CalendarEventMeetingDTO> dtoList = dp.getDataList();
            wrapper.add(new AgentaMeeting(dp.filter.startDate, dtoList));
        }

        //check the current date, if start date is current date then "Today" button disable
        checkCurrentDate();
        return null;
    }

    //wrapper class for meeting
    public class AgentaMeeting {
        public Datetime meetingDate {get; set;}
        public List<MEP_CalendarEventMeetingDTO> meetings {get; set;}
        public AgentaMeeting(Datetime meetingDate, List<MEP_CalendarEventMeetingDTO> meetings) {
            this.meetingDate = meetingDate;
            this.meetings = meetings;
        }
        public Boolean isToDay {
            get {
                if (meetingDate != null) {
                    //if (MEP_DateTimeUtils.convertDateTimeFromGmt(meetingDate.dateGMT(), 'EST').date() == Datetime.now().dateGMT()) {
                    //      return true;
                    //}
                    if (meetingDate.dateGMT() == Datetime.now().dateGMT()) {
                            return true;
                    }
                }
                return false;
            }
        }
    }

    //action for next button
    public void agendaNext() {
        agendaStartDate = agendaStartDate.addDays(1);
        initAgenda();
    }

    //action for prev button
    public void agendaPrev() {
        agendaStartDate = agendaStartDate.addDays(-1);
        initAgenda();
    }

    //action for today button
    public void agendaToday() {
        agendaStartDate = Datetime.now();
        initAgenda();
    }


    private void checkCurrentDate() {
        if (agendaStartDate.date() == Datetime.now().date()) {
            isToDay = true;
        } else {
            isToDay = false;
        }
    }

}