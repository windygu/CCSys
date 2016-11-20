﻿using LasMargaritas.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LasMargaritas.BL.Views
{
    public interface IWeightTicketView
    {
        List<SelectableModel> Producers { get; set; }
        List<SelectableModel> FilterCicles { get; set; }
        List<SelectableModel> Products { get; set; }
        List<SelectableModel> Cicles { get; set; }
        List<SelectableModel> Ranchers { get; set; }
        List<SelectableModel> Suppliers { get; set; }
        List<SelectableModel> SalesCustomers { get; set; }
        List<SelectableModel> WeightTickets { get; set; }
        List<SelectableModel> WareHouses { get; set; }
        int SelectedId { get; set; }
        WeightTicket CurrentWeightTicket { get; set; }
        void HandleException(Exception ex, string method, Guid errorId);        
    }
}
