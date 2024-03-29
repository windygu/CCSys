﻿using System;
using System.ComponentModel;
using System.Drawing;

namespace LasMargaritas.Models
{
    public class SaleCustomer: INotifyPropertyChanged
    {
        public void RaiseUpdateProperties()
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(null));
        }
        public int Id { get; set; }

        public string Name { get; set; }

        public string Address { get; set; }

        public string City { get; set; }

        public string PhoneNumber { get; set; }

        public int StateId { get; set; }

        public string RFC { get; set; }

        public DateTime? StoreTs { get; set; }

        public DateTime? UpdateTs { get; set; }

        public string DistrictOrColony { get; set; }

        public string ZipCode { get; set; }

        public event PropertyChangedEventHandler PropertyChanged;

    }

}
