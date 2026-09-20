export const districts = [
  {
    id: "MH01",
    name: "Mumbai City",
    talukas: [
      { id: "T01", name: "Colaba", villages: ["Cuffe Parade", "Nariman Point", "Fort"] },
      { id: "T02", name: "Byculla", villages: ["Agripada", "Mazgaon", "Nagpada"] }
    ]
  },
  {
    id: "MH02",
    name: "Pune",
    talukas: [
      { id: "T03", name: "Haveli", villages: ["Kothrud", "Wakad", "Hinjewadi", "Baner"] },
      { id: "T04", name: "Mulshi", villages: ["Pirangut", "Paud", "Bhugaon"] }
    ]
  },
  {
    id: "MH03",
    name: "Nagpur",
    talukas: [
      { id: "T05", name: "Nagpur Urban", villages: ["Dharampeth", "Sitabuldi", "Mahal"] },
      { id: "T06", name: "Nagpur Rural", villages: ["Hingna", "Kamptee", "Butibori"] }
    ]
  },
  {
    id: "MH04",
    name: "Nashik",
    talukas: [
      { id: "T07", name: "Nashik", villages: ["Panchavati", "Satpur", "Ambad"] },
      { id: "T08", name: "Igatpuri", villages: ["Ghoti", "Kasara", "Bhavali"] }
    ]
  }
];

export const getDistrictName = (id) => districts.find(d => d.id === id)?.name || id;
export const getTalukasForDistrict = (districtId) => districts.find(d => d.id === districtId)?.talukas || [];
