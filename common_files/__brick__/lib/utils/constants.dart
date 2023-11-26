enum Month {
  jan('January', 'Jan'),
  feb('February', 'Feb'),
  mar('March', 'Mar'),
  apr('April', 'Apr'),
  may('May', 'May'),
  jun('June', 'Jun'),
  jul('July', 'Jul'),
  aug('August', 'Aug'),
  sep('September', 'Sep'),
  oct('October', 'Oct'),
  nov('November', 'Nov'),
  dec('December', 'Dec');

  const Month(this.full, this.short);
  final String full;
  final String short;
}

enum TimeOption {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening'),
  allDay('All day'),
  overnight('Overnight'),
  toBeDecided('To be decided');

  const TimeOption(this.label);

  final String label;
}
