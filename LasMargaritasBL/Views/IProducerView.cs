﻿using LasMargaritas.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LasMargaritas.BL.Views
{
    public interface IProducerView
    {
        List<Producer> Producers { get; set; }

        Producer CurrentProducer { get; set; }

        void HandleException(Exception ex, string method, Guid errorId);
        
    }
}