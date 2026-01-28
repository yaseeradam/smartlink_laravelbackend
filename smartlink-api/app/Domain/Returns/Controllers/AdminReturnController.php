<?php

namespace App\Domain\Returns\Controllers;

use App\Domain\Returns\Models\ReturnRequest;
use App\Domain\Returns\Resources\ReturnResource;
use App\Domain\Returns\Services\ReturnService;

class AdminReturnController
{
    public function __construct(private readonly ReturnService $returnService)
    {
    }

    public function approve(ReturnRequest $returnRequest)
    {
        $updated = $this->returnService->approve(request()->user(), $returnRequest);

        return new ReturnResource($updated);
    }

    public function reject(ReturnRequest $returnRequest)
    {
        $updated = $this->returnService->reject(request()->user(), $returnRequest);

        return new ReturnResource($updated);
    }

    public function complete(ReturnRequest $returnRequest)
    {
        $updated = $this->returnService->complete(request()->user(), $returnRequest);

        return new ReturnResource($updated);
    }
}
