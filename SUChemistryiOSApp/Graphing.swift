//
//  GraphingViewController.swift
//  
//

import UIKit
import Charts
import TinyConstraints

class GraphingViewController: UIViewController, ChartViewDelegate {
 
    lazy var lineChartView: LineChartView = {
           let chartView = LineChartView()
           chartView.backgroundColor = .systemBlue
           
           chartView.rightAxis.enabled = false
           
           let yAxis = chartView.leftAxis
           yAxis.labelFont = .boldSystemFont(ofSize: 12)
           yAxis.setLabelCount(6, force: false)
           yAxis.labelTextColor = .white
           yAxis.axisLineColor = .white
           yAxis.labelPosition = .outsideChart
           
           chartView.xAxis.labelPosition = .bottom
           chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
           chartView.xAxis.setLabelCount(6, force: false)
           chartView.xAxis.labelTextColor = .white
           chartView.xAxis.axisLineColor = .systemBlue
           
           //chartView.animate(xAxisDuration: 2.5)
           
           return chartView
       }()

       override func viewDidLoad() {
           super.viewDidLoad()
           view.addSubview(lineChartView)
           lineChartView.centerInSuperview()
           lineChartView.width(to: view)
           lineChartView.heightToWidth(of: view)
           lineChartView.isUserInteractionEnabled = false
       }
    
    override func viewDidAppear(_ animated: Bool) {
        setData()
    }
       
       func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
           print(entry)
       }
       
       func setData() {
           let set1 = LineChartDataSet(entries: loadData(), label: "Beer's Law")
           
           set1.mode = .cubicBezier
           set1.mode = .linear
           set1.drawCirclesEnabled = true
           set1.lineWidth = 3
           set1.setColor(.white)
           //set1.fill = Fill(color: .white)
           set1.fillAlpha = 0.8
           set1.drawFilledEnabled = true
           
           set1.drawHorizontalHighlightIndicatorEnabled = false
           set1.highlightColor = .systemRed
           
           let data = LineChartData(dataSet: set1)
           data.setDrawValues(true)
           lineChartView.data = data
           
       }
    
    func loadData() -> [ChartDataEntry] {
        var values = [ChartDataEntry]()
        var controlIntensity = -1.0
        
        //Data can only be charted if the control is populated
        let controlFile = "sample0"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let controlURL = DocumentDirURL.appendingPathComponent(controlFile)
        
        do {
            let stringData = try String(contentsOf:controlURL, encoding: .utf8)
            let parsedData = stringData.split(whereSeparator: \.isNewline)
            controlIntensity = Double(parsedData[8]) ?? -1.0
        } catch let error as NSError {
            //If the sample doesn't exist on the disk already, return
            print("Failed to read file: sample0")
            print(error)
            return values
        }
        
        //If no control set, abort graphing
        if(controlIntensity == -1.0) {
            return values
        }
        
        //Open the data files and add each sample to the chart
        for index in 1...5 {
            let fileName = "sample\(index)"
            let fileURL = DocumentDirURL.appendingPathComponent(fileName)
            
            do {
                let stringData = try String(contentsOf:fileURL, encoding: .utf8)
                let parsedData = stringData.split(whereSeparator: \.isNewline)
                let concentration = Double(parsedData[1]) ?? 0.0
                let sampleIntensity = Double(parsedData[8]) ?? -1.0
                
                //If valid sample, add to graph
                if(sampleIntensity != -1.0) {
                    values.append(ChartDataEntry(x: concentration, y:calculateAbsorbance(controlIntensity: controlIntensity, sampleIntensity: sampleIntensity)))
                }
            } catch let error as NSError {
                //If the sample doesn't exist on the disk already, return
                print("Failed to read file: sample0")
                print(error)
                return values
            }
            
        }
        values = values.sorted(by: { $0.x < $1.x })

        print("Graphing")
        print(values)
        return values
    }
    
    //Calculates and returns the absorbance of a sample given its
    //Intensity along with the intensity of the control sample
    func calculateAbsorbance(controlIntensity: Double, sampleIntensity: Double) -> Double {
        //divide by zero
        if(controlIntensity == 0) {
            return 0
        }
        //function will return negative infinity if this case is not accounted for
        if(sampleIntensity == 0) {
            return 1
        }
        let quotient = 1.0 * sampleIntensity / controlIntensity
        return log10(quotient)
    }
   }
