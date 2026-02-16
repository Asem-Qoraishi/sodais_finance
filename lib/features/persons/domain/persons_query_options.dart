enum PersonTypeFilter { all, customers, suppliers, owesYou, youOwe }

enum PersonsOrderBy {
  recentlyActive,
  lastPayment,
  lastReceipt,
  alphabetAsc,
  alphabetDesc,
  highestDebt,
  highestCredit,
  oldest,
  newest,
}

const int personsPageSize = 20;
