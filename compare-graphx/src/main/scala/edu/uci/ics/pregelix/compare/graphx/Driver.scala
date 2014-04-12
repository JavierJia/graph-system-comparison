package edu.uci.ics.pregelix.compare.graphx

import scala.reflect.ClassTag

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.graphx._
import org.apache.spark.graphx.EdgeTriplet

object Driver {

  def pageRank(sc: SparkContext, inputPath: String, maxIterations: Int): Graph[Double, Double] = {
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1.0, 1.0)
    graph.staticPageRank(maxIterations)
  }

  def connectedComponent(sc: SparkContext, inputPath: String): Graph[VertexId, Int] = {
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1, 1)
    graph.connectedComponents
  }

  def triagleCounting(sc: SparkContext, inputPath: String): Graph[Int, Int] = {
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1, 1).partitionBy(PartitionStrategy.RandomVertexCut)
    graph.triangleCount
  }

  def sssp(sc: SparkContext, inputPath: String, givenSource: Option[Long] = None): Graph[Double, Double] = {
    // Initialize the graph such that all vertices except the root have distance infinity.
    var sourceId = givenSource.getOrElse(sc.textFile(inputPath).first.split("\\W+")(0).toLong)
    var graph = GraphLoader.loadWebmap(sc, inputPath, 1.0, Double.PositiveInfinity);
    val initialGraph = graph.mapVertices((id, _) => if (id == sourceId) 0.0 else Double.PositiveInfinity)
    val sssp = initialGraph.pregel(Double.PositiveInfinity)(
      (id, dist, newDist) => math.min(dist, newDist), // Vertex Program
      triplet => { // Send Message
        if (triplet.srcAttr + triplet.attr < triplet.dstAttr) {
          Iterator((triplet.dstId, triplet.srcAttr + triplet.attr))
        } else {
          Iterator.empty
        }
      },
      (a, b) => math.min(a, b) // Merge Message
      )
    sssp
  }

  var master: String = ""
  var memory: String = "1g"
  var cores: Int = Int.MaxValue
  var cmd: String = ""
  var inputPath: String = ""
  var outputPath: String = ""

  def parse(args: List[String]): Option[List[String]] = args match {
    case ("--cores" | "-c") :: value :: tail =>
      cores = value.toInt
      parse(tail)

    case ("--memory" | "-m") :: value :: tail =>
      memory = value
      parse(tail)

    case ("--help" | "-h") :: tail =>
      usage()
      None

    case "cmd" :: _cmd :: _inputPath :: _outputPath :: tail =>
      cmd = _cmd
      inputPath = _inputPath
      outputPath = _outputPath
      Some(tail)

    case _ =>
      usage()
      None
  }

  def usage(ret: Int = 1) {
    System.err.println("Usage: Driver <masterUrl> -c <cores> -m <mems> cmd <cmd> <inputPath> <outputPath> [cmd-specific-args]")
    System.err.println("  --memory <count> (amount of memory, default 1g, allocated for your driver program)")
    System.err.println("  --cores <count> (number of cores allocated for your driver program on cluster Not per machine, default all )")
    System.err.println("  cmd: [PageRank|CC|SSSP|TC]")
    System.err.println("  cmd-specific-args: ")
    System.err.println("    PageRank: [maxIterations] default=10")
    System.err.println("    CC: None")
    System.err.println("    TC: None")
    System.err.println("    SSSP: [sourcId] default=first vertex id in the given file")
    System.exit(ret)
  }

  def main(args: Array[String]) {

    if (args.length < 1) usage(0)
    var conf = new SparkConf().setMaster(args(0)).setAppName("GraphXComparison")
    var extraArgs = parse(args.slice(1, args.length).toList).getOrElse(List.empty)
    System.out.println("extraArgs:" + extraArgs);

    conf.set("spark.executor.memory", memory)
    conf.set("spark.cores.max", cores.toString)

    val sc = new SparkContext(conf)

    cmd.toLowerCase() match {
      case "pagerank" => {
        pageRank(sc, inputPath, if (extraArgs.length > 0) extraArgs(0).trim().toInt else 10).vertices.saveAsTextFile(outputPath)
      }
      case "cc" => {
        connectedComponent(sc, inputPath).vertices.saveAsTextFile(outputPath)
      }
      case "tc" => {
        triagleCounting(sc, inputPath).vertices.saveAsTextFile(outputPath)
      }
      case "sssp" => {
        sssp(sc, inputPath, if (extraArgs.length > 0) Some(extraArgs(0).trim().toLong) else None)
      }
      case _ => {
        System.err.println("cmd is missing")
        usage(1)
      }
    }

    sc.stop()
  }
}